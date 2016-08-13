#region Intro

function Get-Something
{
	param (
		[Parameter()]
		[bool]$Param
	)
	
	## Start the code "flow" which changes direction depending on circumstances
	
	## If $Param was used, do something
	if ($PSBoundParameters.ContainsKey('Param')) {	
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

<# Questions to ask
	1. What are the parameters?
	2. What are all the possible output scenarios?
#>
#endregion

#region Build a Pester unit test

describe 'Get-Something' { ## This name can be anything. When testing functions, I always use the function name
	
	## What is the simplest way this function can be called? Called with no parameters at all.
	## If no parameter is passed, it will essentially skip all the logic we have and just return so test this.
	it 'returns $null when $Param is not used' {
		
		Get-Something | should be $null
		
	}
	
	## Other It blocks would be here building more "complicated" scenarios like using various parameters.
}
#endregion

## Invoke Pester to run the test

"Invoke-Pester -Path 'C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\UnitTestIntro.ps1'" | Set-Clipboard