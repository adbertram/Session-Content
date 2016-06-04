describe 'New-EmployeeOnboardUser' {

	$credential = Get-Credential
	$commonAdParams = @{
		'Credential' = $credential
	}
	
	context 'Default parameters'  {
		
		$userName = 'IUser'
		
		it 'creates the user with the first choice username' 	{
			
			Get-ADUser @commonAdParams -Filter "Name -eq '$userName'" | should not be $null
			
		}
		
		it 'creates the user in the right OU' {
			
			Get-ADUser @commonAdParams -Filter "Name -eq '$userName'" | should be "CN=$userName,OU=Corporate Users,DC=mylab,DC=local"
			
		}
		
		it 'adds the user to the default group' {
			
			$DefaultGroup = 'All Users'
			
			((Get-ADGroupMember @commonAdParams -Identity $DefaultGroup).Name).where({ $_ -eq $userName }) | should not be $null
			
		}
		
		it 'creates the user home folder' {
			
			$path = "\\MEMBERSRV1\Users\$userName"
			Test-Path -Path $path | should be $true
		}
	}
	
	context 'With department'  {
		
		$userName = 'ISecondUser'
		
		it 'creates the user with the first choice username' {
			
			Get-ADUser @commonAdParams -Filter "Name -eq '$userName'" | should not be $null
			
		}
		
		it 'creates the user in the right OU' {
			
			Get-ADUser @commonAdParams -Filter "Name -eq '$userName'" | should be "CN=$userName,OU=Corporate Users,DC=mylab,DC=local"
			
		}
		
		it 'adds the user to the default group' {
			
			$DefaultGroup = 'All Users'
			
			((Get-ADGroupMember @commonAdParams -Identity $DefaultGroup).Name).where({ $_ -eq $userName }) | should not be $null
			
		}
		
		it 'adds the user to the department group' {
			
			$Department = 'Accounting'
			
			((Get-ADGroupMember @commonAdParams -Identity $Department).Name).where({ $_ -eq $userName }) | should not be $null
			
			
		}
		
		it 'creates the user home folder' {
			
			$path = "\\MEMBERSRV1\Users\$userName"
			Test-Path -Path $path | should be $true
		}
	}
}