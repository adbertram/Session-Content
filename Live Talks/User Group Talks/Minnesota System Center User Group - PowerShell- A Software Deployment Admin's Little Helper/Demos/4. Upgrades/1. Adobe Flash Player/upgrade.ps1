Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
if (Test-InstalledSoftware -Name 'Adobe Flash Player 10 Plugin' -Version '10.1.53.64') {
    & "$WorkingDir\uninstall.ps1"
}

## Start the installer
Install-Software -OtherInstallerFilePath "$WorkingDir\install_flash_player_11_plugin_11.3.300.268.exe" -OtherInstallerArgs '-install'
if (Test-InstalledSoftware -Name 'Adobe Flash Player 11 Plugin' -Version '11.3.300.268') {
    Write-Log -Message 'Adobe Flash Player 11 has been successfully installed'
} else {
    Write-Log -Message 'Adobe Flash Player 11 failed to install' -LogLevel 3
}
