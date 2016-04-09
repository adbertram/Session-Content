Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log

if (Test-InstalledSoftware -Name 'EMET 5.5')
{
	$true
}