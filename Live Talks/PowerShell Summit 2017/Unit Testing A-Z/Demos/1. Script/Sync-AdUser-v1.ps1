<#
This is a typical procedural PowerShell script. It is used to "sync" a number of employees stored in a CSV file
to Active Directory. This is the first version. This version mimics a "v1" of a typical script you might use in your
daily work life. You've got a set of requirements like HR handing you a CSV and saying they need that information
populated in Active Directory. They have an initial set of requirements. The next version is a result of your manager
coming to you and requesting changes.
#>

$artifactsFolder = "$($PSScriptRoot | Split-Path -Parent)\Artifacts"

## The default password for account was saved on the file system previously
$defaultPasswordXmlFile = "$artifactsFolder\DefaultUserPassword.xml"
## To save a new password, do this: Get-Credential -UserName 'DOESNOTMATTER' | Export-CliXml $defaultPasswordXmlFile
$defaultCredential = Import-CliXml -Path $defaultPasswordXmlFile
$defaultPassword = $defaultCredential.GetNetworkCredential().Password
$defaultPassword = (ConvertTo-SecureString $defaultPassword -AsPlainText -Force)

## Read the CSV
$employeesCsvPath = "$artifactsFolder\Employees.csv"
if (-not (Test-Path -Path $employeesCsvPath)) {
	throw "The employee CSV file at [$($employeesCsvPath)] could not be found."
}

$employees = Import-Csv -Path $employeesCsvPath

if ($employees) { ## Checking to see if there was actually any employees in the CSV
	foreach ($employee in $employees)
	{
		try ## A try/catch blog to catch errors
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
				## Create the user account with the details from the CSV
				$NewUserParams = @{
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
				Write-Verbose -Message "Creating the new user account [$($userName)]..."
				New-AdUser @NewUserParams	
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