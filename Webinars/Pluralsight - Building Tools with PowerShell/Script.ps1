## Example Active Directory Account Automator #1: A Script ##

$Employees = Import-Csv -Path C:\Users.csv ## BAD: File path in the script itself
foreach ($Employee in $Employees)
{
	#region Create the AD user account
    ## BAD: What if the desired username is taken? No validation here to check and
	## try to use another scheme
	$Username = "$($Employee.FirstName.SubString(0, 1))$($Employee.LastName)"
	$NewUserParams = @{
		'Title' = $Employee.Title
        'UserPrincipalName' = $Username
		'Name' = $Username
		'GivenName' = $Employee.FirstName
		'Surname' = $Employee.LastName
		'SamAccountName' = $Username
        'Department' = $Employee.Department
		## Password in clear text (not solving this in this webinar) and it's in the
		## script. BAD: This should be a parameter.
		'AccountPassword' = (ConvertTo-SecureString 'p@$$w0rd12' -AsPlainText -Force)
		'Enabled' = $true
		'Initials' = $Employee.MiddleInitial
		'ChangePasswordAtLogon' = $true
	}
	if ($Employee.UserOU)
	{
		$NewUserParams.Path = "$($Employee.UserOU),DC=lab,DC=local" ## What if we need another domain?
	}
	
	New-AdUser @NewUserParams
	#endregion
	
	#region Add the user to the standard group
	## BAD: Group name in the script.
	Add-ADGroupMember -Identity 'Gigantic Corporation Inter-Intra Synergy Group' -Members $Username
	#endregion
	
	#region Create the employee's AD computer account
	## BAD: Static OU path in the script
	New-ADComputer -Name $Employee.Computername -Path 'OU=Corporate Computers,DC=lab,DC=local'
	#endregion
}