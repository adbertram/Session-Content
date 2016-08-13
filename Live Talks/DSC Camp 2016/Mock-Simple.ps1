function Hello-World
{
	Write-Output -InputObject 'I am in the Hello-World function'
}

#Hello-World


describe 'SimpleMockExample' {
	
	it 'returns what I would expect without mocking' {
		
		Hello-World | should be 'I am in the Hello-World function'
	}
	
	it 'returns something new when mocked' {
		
		mock 'Write-Output' {
			return 'I have been mocked!'
		}
		
		Hello-World | should be 'I have been mocked!'
		
	}
	
}

"Invoke-Pester -Path 'C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\Mock-Simple.ps1'" | Set-Clipboard