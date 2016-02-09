Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
Get-InstalledSoftware -Name 'Adobe Reader XI' | Remove-Software -KillProcess 'AcroRd32', 'Acrobat.com', 'Adobe_Updater'
Remove-ProfileItem 'AppData\Local\Adobe\Acrobat', 'AppData\LocalLow\Adobe\Acrobat', 'AppData\Roaming\Acrobat'
