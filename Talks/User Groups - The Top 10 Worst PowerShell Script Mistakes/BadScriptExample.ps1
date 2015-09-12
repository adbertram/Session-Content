function Receive-Output
{
	process { Write-Host $_ -ForegroundColor Green }
}

Write-Output "this is a test" | Receive-Output
Write-Host "this is a test" | Receive-Output
Write-Output "this is a test"