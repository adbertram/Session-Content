Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager

if (Test-InstalledSoftware -Name 'Adobe Reader XI')
{
	$true
}