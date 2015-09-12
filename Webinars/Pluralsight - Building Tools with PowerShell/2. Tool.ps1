[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
	[string]$EmployeesCsv,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
	[string]$FunctionsScript = '.\AdAccountManagementAutomator.ps1'
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
				$NewUserParams = @{
					'FirstName' = $Employee.FirstName
					'MiddleInitial' = $Employee.MiddleInitial
					'LastName' = $Employee.LastName
					'Title' = $Employee.Title
				}
				if ($Employee.UserOU)
				{
					$NewUserParams.Location = $Employee.UserOU
				}
				## Grab the username created to use for Set-MyAdUser
				New-EmployeeOnboardUser @NewUserParams
				#endregion
				
				#region Create the employee's AD computer account
				New-EmployeeOnboardComputer -Computername $Employee.Computername
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
	Write-Error $_.Exception.Message
}