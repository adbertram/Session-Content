Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

if (-not (Test-InstalledSoftware -Name 'EMET 5.1')) {
    if (((Get-OperatingSystem) -match 'Windows 7') -and (-not (Test-InstalledSoftware -Name 'Microsoft .NET Framework 4 Client Profile'))) {
        Install-Software -OtherInstallerFilePath "$WorkingDir\dotNetFx40_Full_x86_x64.exe" -OtherInstallerArgs '/q /norestart'
    }
    if (Install-Software -MsiInstallerFilePath "$WorkingDir\EMET 5.1 Setup.msi") { ## msiexec.exe /i "EMET 5.1 Setup.msi" /qn REBOOT=ReallySuppress
        if (Test-InstalledSoftware -Name 'EMET 5.1') {
            Write-Host 'EMET installed successfully!' -ForegroundColor Green
        } else {
            Write-Host 'EMET failed to install' -ForegroundColor Red
        }
    } else {
        Write-Host 'EMET failed to install' -ForegroundColor Red
    }
} else {
    Write-Host 'EMET 5.1 is already installed'
}