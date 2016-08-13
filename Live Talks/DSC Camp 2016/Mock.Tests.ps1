

describe 'BasicScript' {
	
	$params = @{
		FilePath = 'C:\MyFile.txt'
	}
	
	it 'throws an exception if a file already exists' {
		
		mock 'Test-Path' {
			return $true
		}
		
		## Run the script and test output by enclosing the call in curly braces to capture the exception
		{ & "$PSScriptRoot\BasicScript.ps1" @params } | should throw 'A file already exists'
	}
	
	it 'returns 1 object(s) of type string if -PassThru is used and no file already exists' {
		
		mock 'Test-Path' {
			return $false
		}
		
		mock 'Add-Content' {
			return 'someimportantvalue'
		}
		
		$params.PassThru = $true
		
		$result = & "$PSScriptRoot\BasicScript.ps1" @params
		@($result).Count | should be 1
		$result | should beoftype 'string'
	}
	
	it 'returns $null when -PassThru is not used and no file already exists' {
		
		mock 'Test-Path' {
			return $false
		}
		
		mock 'Add-Content' {
			return 'someimportantvalue'
		}
		
		$params.PassThru = $false
		
		$result = & "$PSScriptRoot\BasicScript.ps1" @params
		$result | should be $null
		
	}
}

"Invoke-Pester -Path 'C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\Mock.Tests.ps1'" | Set-Clipboard