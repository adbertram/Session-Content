Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

## This upgrade example shows calling the already built uninstall script,
## testing for the existing of critical files in the upgrade script
## and finally installing a simple MSI.  The simple MSI install method was
## found to not be sufficient because the EULA comes up at first run
## so a MST was created to silence this.
if (Test-InstalledSoftware -Name 'Adobe Reader 7.0')
{
	& "$WorkingDir\uninstall.ps1"
}

if (-not (Test-Path -Path "$WorkingDir\AcroRead.msi" -PathType Leaf))
{
	Write-Log -Message "The installer $WorkingDir\AcroRead.msi can't be found" -LogLevel 3
	exit 2
}
elseif (-not (Test-Path -Path "$WorkingDir\SuppressEula.mst" -PathType Leaf))
{
	Write-Log -Message "The MST $WorkingDir\SuppressEula.mst can't be found" -LogLevel 3
	exit 2
}
Install-Software -MsiInstallerFilePath "$WorkingDir\AcroRead.msi" -MstFilePath "$WorkingDir\SuppressEula.mst"
