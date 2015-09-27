Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
Get-InstalledSoftware -Name 'EMET 5.1' | Remove-Software
