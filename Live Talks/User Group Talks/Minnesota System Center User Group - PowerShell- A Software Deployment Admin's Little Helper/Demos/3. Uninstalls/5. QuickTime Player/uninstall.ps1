Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
# Pretend like we've exchausted all other options
$Guid = (Get-InstalledSoftware -Name 'Apple Application Support').GUID
Uninstall-ViaMsizap -MsizapFilePath 'C:\MyDeployment\msizap.exe' -Guid $Guid

$Guid = (Get-InstalledSoftware -Name 'QuickTime 7').GUID
Uninstall-ViaMsizap -MsizapFilePath 'C:\MyDeployment\msizap.exe' -Guid $Guid
