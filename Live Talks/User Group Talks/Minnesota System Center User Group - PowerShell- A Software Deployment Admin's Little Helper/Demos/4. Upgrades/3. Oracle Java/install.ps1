Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

## Stop the Program Compatbiility Assistance service.  It interferes with installing old versions
Get-Service -Name PcaSvc -ErrorAction SilentlyContinue | Stop-Service

$OldInstallers = @(
    'jre-6u20-windows-i586-s.exe',
    'jre-7u2-windows-i586.exe',
    'jre-6u16-windows-i586.exe'
)
foreach ($OldInstall in $OldInstallers) {
    if (($OldInstall -eq 'jre-6u20-windows-i586-s.exe') -and (-not (Test-InstalledSoftware -Name 'Java(TM) 6 Update 20'))) {
        Install-Software -OtherInstallerFilePath "$WorkingDir\$OldInstall" -OtherInstallerArgs '/s'    
    }
    if (($OldInstall -eq 'jre-7u2-windows-i586.exe') -and (-not (Test-InstalledSoftware -Name 'Java(TM) 7 Update 2'))) {
        Install-Software -OtherInstallerFilePath "$WorkingDir\$OldInstall" -OtherInstallerArgs '/s'    
    }
    if (($OldInstall -eq 'jre-6u16-windows-i586.exe') -and (-not (Test-InstalledSoftware -Name 'Java(TM) 6 Update 16'))) {
        Install-Software -OtherInstallerFilePath "$WorkingDir\$OldInstall" -OtherInstallerArgs '/s'    
    }
    
}
