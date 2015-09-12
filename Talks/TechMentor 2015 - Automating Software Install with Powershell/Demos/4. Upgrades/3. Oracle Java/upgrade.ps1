Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
& "$WorkingDir\uninstall.ps1"

Install-Software -OtherInstallerFilePath "$WorkingDir\jre-8u45-windows-i586.exe" -OtherInstallerArgs '/s'
