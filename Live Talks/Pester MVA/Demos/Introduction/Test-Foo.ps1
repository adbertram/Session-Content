function Test-Foo {
	param(
		$FilePath
	)

	if (Select-String -Path $FilePath -Pattern 'foo') {
		$true
	} else {
		$false
	}
}