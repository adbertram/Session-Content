. "$PSScriptRoot\Test-Foo.ps1"

describe 'Test-Foo' {
	Add-Content -Path TestDrive:\foofile.txt -Value 'foo'
	Add-Content -Path TestDrive:\nofoofile.txt -Value 'not here'

	it 'when the file has "foo" in it, it should return $true' {
		Test-Foo -FilePath TestDrive:\foofile.txt | should be $true
	}

	it 'when the file does not have "foo" in it, it should return $false' {
		Test-Foo -FilePath TestDrive:\nofoofile.txt | should be $false
	}
}