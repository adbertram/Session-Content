## Example Active Directory Account Automator #1: A Tool ##

[CmdletBinding()] ## We're talkin' advanced here
param (
	[Parameter(Mandatory)] ## Parameters are a great way to prevent from modifying the script
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -Path $_ -PathType Leaf })] ## Validation
	[string]$EmployeesCsv,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -Path $_ -PathType Leaf })] ## Validation
	[string]$FunctionsScript = "C:\Dropbox\Powershell\GitRepos\Session-Content\Webinars\Pluralsight - Building Tools with PowerShell\AdAccountManagementAutomator.ps1"
)

try
{
	## Take out code that is reused over and over into functions and preferably get them out
	## out of your main script into a script with functions (or a module)
	. $FunctionsScript
	
	$Employees = Import-Csv -Path $EmployeesCsv
	if ($Employees) ## Checking to see if there was actually any employees in the CSV
	{
		foreach ($Employee in $Employees)
		{
			try ## A try/catch blog to catch errors
			{
				#region Create AD user account and add to standard group
                ## Far fewer parameters
				$NewUserParams = @{
					'FirstName' = $Employee.FirstName
					'MiddleInitial' = $Employee.MiddleInitial
					'LastName' = $Employee.LastName
					'Title' = $Employee.Title
                    'Department' = $Employee.Department
                    'Verbose' = $VerbosePreference
				}
				if ($Employee.UserOU)
				{
					$NewUserParams.Location = $Employee.UserOU
				}

				New-EmployeeOnboardUser @NewUserParams 
				#endregion
				
                $newComputersParams = @{
                    'ComputerName' = $Employee.Computername
                    'Verbose' = $VerbosePreference
                }
				#region Create the employee's AD computer account
				New-EmployeeOnboardComputer @newComputersParams
				#endregion
			}
			catch
			{
				Write-Error $_.Exception.Message
			}
		}
	}
	else
	{
		Write-Warning "No records found in the file [$($EmployeesCsv)]"	
	}
}
catch
{
	Write-Error $_.Exception.Message ## Error handling
}