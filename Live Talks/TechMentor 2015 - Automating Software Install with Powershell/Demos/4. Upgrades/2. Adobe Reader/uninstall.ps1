Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

Stop-MyProcess 'AcroRd32', 'Acrobat.com', 'Adobe_Updater' -Verbose

Start-Process "$WorkingDir\AdbeArCleaner_v2.exe" -ArgumentList '/silent /product=1' -Wait -NoNewWindow
Get-InstalledSoftware -Name 'Adobe Reader 7.0' -Verbose | Remove-Software -Verbose
Remove-ProfileItem 'AppData\Local\Adobe\Acrobat', 'AppData\LocalLow\Adobe\Acrobat', 'AppData\Roaming\Acrobat' -Verbose