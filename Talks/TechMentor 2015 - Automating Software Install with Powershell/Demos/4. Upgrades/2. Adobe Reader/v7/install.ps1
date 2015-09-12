Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

if (-not (Test-Path -Path "$WorkingDir\Adobe Reader 7.0.msi" -PathType Leaf)) {
    Write-Log -Message "The installer $WorkingDir\Adobe Reader 7.0.msi can't be found" -LogLevel 3
    exit 2
}
Install-Software -MsiInstallerFilePath "$WorkingDir\Adobe Reader 7.0.msi"
