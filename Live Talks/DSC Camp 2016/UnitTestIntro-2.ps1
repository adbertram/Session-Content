function Get-Something
{
	param (
		[Parameter()]
		[bool]$Param
	)
	
	## Start the code "flow" which changes direction depending on circumstances
	
	## If $Param was used, do something
	if ($PSBoundParameters.ContainsKey('Param'))
	{
		if ($Param -eq $true)
		{
			## Return a pscustomobject if Param is true
			[pscustomobject]@{
				'Property1' = 'Value1'
				'Property2' = 'Value2'
			}
		}
		else
		{
			## Return [bool]$false if Param is $false
			$false
		}
	}
	## If $Param is not used, it will return nothing
}

describe 'Get-Something' {

	## What's the next simplest iteration of using Get-Something? Using $Param using either $true or $false. 
	## Test the output when using $Param either way.
	it 'returns a single pscustomobject with expected properties and values when $Param is [bool]$true' {
		
		$result = Get-Something -Param $true
		
		## Ensure an object type of pscustomobject is returned
		$result | should beoftype 'pscustomobject'
		
		## Ensure a single pscustomobject is returned
		@($result).Count | should be 1
		
		## Ensure the pscustomobject has the right properties
		$testPropNameParams = @{
			ReferenceObject = ($result | Get-Member -MemberType NoteProperty).Name
			DifferenceObject = @('Property1', 'Property2')
		}
		Compare-Object @testPropNameParams | should be $null
		
		## Ensure the pscustomobject has the right property values
		$testPropNameParams = @{
			ReferenceObject = ($result.PSObject.Properties).Value
			DifferenceObject = @('Value1', 'Value2')
		}
		Compare-Object @testPropNameParams | should be $null
	}
	
	it 'returns [bool]$false when $Param is [bool]$false' {
		
		$result = Get-Something -Param $false
		$result | should beoftype 'bool'
		$result | should be $false
		
	}
}
#endregion

## Invoke Pester to run the test

"Invoke-Pester -Path 'C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\UnitTestIntro-2.ps1'" | Set-Clipboard

#region Summary

<# Unit Tests

	- Tests code execution ONLY
	- Does not touch anything in the environment

	What to Test?
	----------------
	- Best case scenario: Test every input, output and code flow possible
	- Test every possible parameter and all combinations thereof
		- Did it return the right output?
		- Did it follow the logical flow that you expected?
#>

#endregion