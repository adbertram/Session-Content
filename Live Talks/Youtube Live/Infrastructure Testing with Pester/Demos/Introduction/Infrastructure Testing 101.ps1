## Some outside process creates an AD user for some purpose

$UserName = 'jjones'
$NewUserParams = @{
    'UserPrincipalName' = $Username
	'Name' = $Username
	'GivenName' = 'Joe'
	'Surname' = 'Jones'
	'Title' = 'Manage of Accounting'
	'SamAccountName' = $Username
	'AccountPassword' = (ConvertTo-SecureString 'DoNotDoThis.' -AsPlainText -Force)
	'Enabled' = $true
	'Initials' = 'D'
	'Path' = "OU=Accounting,DC=mylab,DC=local"
	Server = 'DC'
}
	
New-AdUser @NewUserParams

## What changes did we INTEND to make to the environment? Look at the parameter values.

describe 'AD User Creation' {

	## Arrange/Act --execute the stuff to minimize code in the assertions
	$adUser = Get-AdUser -Server DC -Identity $UserName -Properties *

	## Notice reusing the parameter values in the assertions
	it 'should have the expected title' {
		$adUser.Title | should be $NewUserParams.Title
	}

	it 'should be enabled' {
		$adUser.Enabled | should be $NewUserParams.Enabled
	}

	it 'should have the expected middle initial' {
		$adUser.Initials | should be $NewUserParams.Initials
	}

	it 'should have the expected first name' {
		$adUser.GivenName | should be $NewUserParams.GivenName
	}

	it 'should have the expected last name' {
		$adUser.SurName | should be $NewUserParams.SurName
	}

	it 'should have the expected department' {
		$adUser.Department | should be $NewUserParams.Department
	}

	it 'should be in the expected OU' {
		$adUser.DistinguishedName | should belike "*$($NewUserParams.Path)"
	}

	## .....
}