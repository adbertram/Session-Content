Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

if (-not (Test-Path -Path "$WorkingDir\AcroRead.msi" -PathType Leaf)) {
    Write-Log -Message "The installer $WorkingDir\AcroRead.msi can't be found" -LogLevel 3
    exit 2
} elseif (-not (Test-Path -Path "$WorkingDir\SuppressEula.mst" -PathType Leaf)) {
    Write-Log -Message "The MST $WorkingDir\SuppressEula.mst can't be found" -LogLevel 3
    exit 2
}
#Install-Software -MsiInstallerFilePath "$WorkingDir\AcroRead.msi"
Install-Software -MsiInstallerFilePath "$WorkingDir\AcroRead.msi" -MstFilePath "$WorkingDir\SuppressEula.mst"
