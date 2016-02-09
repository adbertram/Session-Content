Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

$FeatureName = 'SNMP-Service'
if ((Get-OperatingSystem) -match 'Server') {
    Write-Log -Message "The operating system is $(Get-OperatingSystem)"
    if (-not (Get-WindowsFeature -Name $FeatureName).Installed) {
        Write-Log -Message "The $FeatureName Windows feature is not installed on $(hostname). Installing now"
        $null = Add-WindowsFeature $FeatureName
        $null = New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers' -Name '1' -Value 'snmp-polling.domain.local' -Force
        $null = New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities' -Name '4' -Value 'snmpstring' -Force
        if ((Get-WindowsFeature -Name $FeatureName).Installed) {
            Write-Log -Message "The $FeatureName Windows feature installed successfully"
        } else {
            Write-Log -Message "The $FeatureName Windows feature failed to install" -LogLevel 3
        }        
    } else {
        Write-Log -Message "The $FeatureName Windows feature is already installed on $(hostname)"
    }
} else {
    Write-Log "The computer $(hostname) is not running a server operating system"
}
