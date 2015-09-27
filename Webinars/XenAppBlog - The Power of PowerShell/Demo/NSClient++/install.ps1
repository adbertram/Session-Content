Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

try
{
	if (-not (Test-InstalledSoftware -Name 'NSClient++' -Version '0.4.2.93'))
	{
		$Architecture = Get-Architecture
		if ($Architecture -eq 'x86')
		{
			$Installer = "$WorkingDir\NSCP-0.4.2.93-x86.msi"
		}
		else
		{
			$Installer = "$WorkingDir\NSCP-0.4.2.93-x64.msi"
		}
		Install-Software -MsiInstallerFilePath $Installer -KillProcess 'nscp'
		
		$InstalledPath = "$($env:SystemDrive)\Program Files\NSClient++"
		if (-not (Test-Path -Path $InstalledPath -PathType Container))
		{
			throw "The install folder [$($InstalledPath)] does not exist"
		}
		else
		{
			## Copy necessary files/folders to the install directory
			Copy-Item "$WorkingDir\*.ini" "$($env:SystemDrive)\Program Files\NSClient++\" -Force
			Copy-Item "$WorkingDir\NRPE_NT" "$($env:SystemDrive)\Program Files\NSClient++\" -Force -Recurse
			Copy-Item "$WorkingDir\Scripts" "$($env:SystemDrive)\Program Files\NSClient++\" -Force -Recurse
		}
	}
	else
	{
		Write-Log 'NSClient++ v0.4.2.93 is already installed'
	}
}
catch
{
	Write-Log $_.Exception.Message -LogLevel 3
}
