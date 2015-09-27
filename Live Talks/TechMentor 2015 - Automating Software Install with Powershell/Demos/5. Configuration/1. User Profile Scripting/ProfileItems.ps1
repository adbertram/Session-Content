Import-Module C:\MyDeployment\SoftwareInstallManager.psm1 -DisableNameChecking

## Create a file on every user's desktop
$FileName = 'Sometextfile.txt'
Get-UserProfilePath | Where {Test-Path "$_\Desktop" } | foreach { $null = New-Item -Path "$_\Desktop" -Type File -Name $FileName }

## Ensure that the file was created
Get-UserProfilePath | Where {Test-Path "$_\Desktop" } | foreach { Get-Item -Path "$_\Desktop\$FileName" -ErrorAction SilentlyContinue } | Select-Object FullName

## Remove the file
Remove-ProfileItem -Path "Desktop\$FileName"

## Check for the file again and it should be gone
Get-UserProfilePath | Where {Test-Path "$_\Desktop" } | foreach { Get-Item -Path "$_\Desktop\$FileName" -ErrorAction SilentlyContinue } | Select-Object FullName