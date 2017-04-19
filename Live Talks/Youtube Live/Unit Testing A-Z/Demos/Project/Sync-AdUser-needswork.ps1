[CmdletBinding()]
param()
<#
This is a typical procedural PowerShell script. It is used to "sync" a number of employees stored in a CSV file
to Active Directory. This mimics a typical script you might use in your
daily work life. You've got a set of requirements like HR handing you a CSV and saying they need that information
populated in Active Directory. They have an initial set of requirements. 

This script:

 - Attempts to find a corresponding AD account based on the FirstName/LastName of a CSV throw
 - If found, it skips. If not, it creates a user based on attribute in that CSV row
 - It adds the user account to a departmental group
 - It also disables any user NOT in the CSV
#>

$domainDn = (Get-ADDomain).DistinguishedName

$artifactsFolder = "$PSScriptRoot\Artifacts"

## The default password for account was saved on the file system previously
$defaultPasswordXmlFile = "$artifactsFolder\DefaultUserPassword.xml"
## To save a new password, do this: Get-Credential -UserName 'DOESNOTMATTER' | Export-CliXml $defaultPasswordXmlFile
Write-Verbose -Message "Reading default password from [$("$artifactsFolder\DefaultUserPassword.xml")]..."
$defaultCredential = Import-CliXml -Path $defaultPasswordXmlFile
$defaultPassword = $defaultCredential.GetNetworkCredential().Password
$defaultPassword = (ConvertTo-SecureString $defaultPassword -AsPlainText -Force)

## Read the CSV
$employeesCsvPath = "$artifactsFolder\Employees.csv"
if (-not (Test-Path -Path $employeesCsvPath)) {
	throw "The employee CSV file at [$($employeesCsvPath)] could not be found."
} else {
	Write-Verbose -Message "The employee CSV file at [$($employeesCsvPath)] exists."
}

$employees = Import-Csv -Path $employeesCsvPath

if ($employees) { ## Checking to see if there was actually any employees in the CSV
	foreach ($employee in $employees)
	{
		try
		{
			## Our standard username pattern is <FirstInitial><LastName>
			$firstInitial = $employee.FirstName.SubString(0,1)
			$userName = '{0}{1}' -f $firstInitial,$employee.LastName
			
			## Check to see if the username is available
			Write-Verbose -Message "Checking if [$($userName)] is available"
			if (Get-ADUser -Filter "Name -eq '$userName'")
			{
				Write-Warning -Message "The username [$($userName)] is not available. Cannot create account."
			}
			else
			{
				Write-Verbose -Message "The username [$($userName)] is available."
				$newUserParams = @{
					UserPrincipalName = $userName
					Name = $userName
					GivenName = $employee.FirstName
					Surname = $employee.LastName
					Title = $employee.Title
					Department = $employee.Department
					SamAccountName = $userName
					AccountPassword = $defaultPassword
					Enabled = $true
					ChangePasswordAtLogon = $true
				}
				
				## Add users to specific OUs depending on department

				## Does the departmental OU even exist yet?
				$departmentOuPath = "OU=$($employee.Department),$domainDn"
				if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$departmentOuPath'")) {
					## if not, throw an error
					throw "Unable to find the OU [$($departmentOuPath)]."
				} else {
					Write-Verbose -Message "Adding [$($userName)] to the OU [$($departmentOuPath)]..."
					$newUserParams.Path = $departmentOuPath
				}

				## Create the user account with the details from the CSV
				Write-Verbose -Message "Creating the new user account [$($userName)]..."
				New-AdUser @newUserParams
			}

			## Adding to department group

			## Check to see if the group exists
			if (-not (Get-ADGroup -Filter "Name -eq '$($employee.Department)'")) {
				throw "Unable to find the group [$($employee.Department)]"
			} else {
				## If so, check to see if the user is already a member
				$groupMembers = (Get-ADGroupMember -Identity $employee.Department).Name
				if (-not ($userName -in $groupMembers)) {
					## Add the username to the department group
					Write-Verbose -Message "Adding [$($userName)] to the group [$($employee.Department)]"
					Add-ADGroupMember -Identity $employee.Department -Members $userName
				} else {
					Write-Verbose -Message "[$($userName)] is already a member of [$($employee.Department)]"
				}
			}
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}
else
{
	Write-Warning "No records found in the file [$($employeesCsvPath)]"	
}

$nonEmployeeAdUsers = $adUsers.where({ $_.samAccountName -notin $employeeUserNames })
foreach ($emp in $nonEmployeeAdUsers) {
	$emp | Disable-AdAccount
}