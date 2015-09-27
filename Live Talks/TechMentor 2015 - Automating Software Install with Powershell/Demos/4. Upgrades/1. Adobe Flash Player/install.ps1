Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

## This installs the old version of Flash for the demo
if (-not (Test-InstalledSoftware -Name 'Adobe Flash Player 10 Plugin' -Version '10.1.53.64')) {
    Install-Software -OtherInstallerFilePath "$WorkingDir\install_flash_player_10.1_non-ie.exe" -OtherInstallerArgs '-install'
} else {
    Write-Log -Message 'Adobe Flash Player 10 is already installed'    
}
