Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

## Install QuickTime Player for demo purposes on launch server
Install-Software -MsiInstallerFilePath "$WorkingDir\AppleApplicationSupport.msi"
Install-Software -MsiInstallerFilePath "$WorkingDir\QuickTime.msi"
