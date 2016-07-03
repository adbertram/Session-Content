#region Demo setup
$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\Ipswitch - Top 5 tasks IT administrators can automate'

## Cleanup existing home folders
'IUser', 'ISecondUser', 'BNumber1', 'BNumber2', 'BNumber3' | foreach { del "\\MEMBERSRV1\Users\$_" -ea SilentlyContinue }

## Exit any existing sessions

# Revert VM
icm -computer hypervsrv -ScriptBlock { get-vm dc | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false }
#endregion

## Dot source the function into the session so it's available
. "$demoPath\Automating New Employee Provisioning-Function.ps1"

## Review the function
ise "$demoPath\Automating New Employee Provisioning-Function.ps1"

#region Provision a single user account

$credential = Get-Credential

#region Create a user accepting all default values

$params = @{
	'FirstName' = 'IpSwitch'
	'LastName' = 'User'
	'Verbose' = $true
	'Credential' = $credential
}

New-EmployeeOnboardUser @params

#endregion

#region Create a user and add a department

$params.FirstName = 'IpSwitch'
$params.LastName = 'SecondUser'
$params.Department = 'Accounting'

$username = 'ISecondUser'

New-EmployeeOnboardUser @params

#endregion

## Attempt to create the user account again

New-EmployeeOnboardUser @params

## Ensure both accounts were created as we had intended --introducing Pester
Invoke-Pester "$demoPath\Automating New Employee Provisioning.Tests.ps1"

## Briefly review Pester tests
ise "$demoPath\Automating New Employee Provisioning.Tests.ps1"

#endregion

#region Provision a bunch of user accounts from a CSV file

## Show the CSV file

Import-Csv -Path "$demoPath\Users.csv"

## Pipe the contents of the CSV file to our function

Import-Csv -Path "$demoPath\Users.csv" | New-EmployeeOnboardUser -Credential $credential -Verbose

## Ensure all of the accounts were created

(Import-Csv -Path "$demoPath\Users.csv").foreach({ Get-ADUser -Credential $credential -Filter "SurName -eq '$($_.LastName)' -and givenName -eq '$($_.FirstName)'"})

#endregion
