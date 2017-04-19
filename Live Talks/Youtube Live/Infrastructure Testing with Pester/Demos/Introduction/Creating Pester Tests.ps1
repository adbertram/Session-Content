## This will be run LAST. This is after we first ensure all the dependencies are satisfied for the test
## and we've gathered up all actual and expected configuration items.
## This is the easy part.

describe 'New-TestEnvironment' {

	it "creates the expected forest" {
		$forest.Name | should be $expectedAttributes.NonNodeData.DomainName
	}

	it 'creates all expected AD Groups' {

		@($actualGroups | where { $_ -in $expectedGroups }).Count | should be @($expectedGroups).Count

	}

	it 'creates all expected AD OUs' {

		@($actualOuDns | where { $_ -in $expectedOuDns }).Count | should be @($expectedOuDns).Count
		
	}

	it 'creates all expected AD users' {
		
		foreach ($user in $expectedUsers)
		{
			$expectedUserName = ('{0}{1}' -f $user.FirstName.SubString(0, 1), $user.LastName)
			$actualUserMatch = $actualUsers | where {$_.SamAccountName -eq $expectedUserName}
			$actualUserMatch | should not benullorempty     
			$actualUserMatch.givenName | should be $user.FirstName
			$actualUserMatch.surName | should be $user.LastName
			$actualUserMatch.Department | should be $user.Department
			$actualUserMatch.DistinguishedName | should be "CN=$expectedUserName,OU=$($user.Department),$domainDn"
		}
	}
}