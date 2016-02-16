Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log

Get-InstalledSoftware -Name 'EMET 5.5' | Remove-Software