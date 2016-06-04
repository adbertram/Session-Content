Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

$SoftwareInstallers = @(
	@{ 'Title' = 'Cisco AnyConnect Secure Mobility Client'; 'Version' = '3.1.05182'; 'Installer' = 'anyconnect-win-3.1.05182-pre-deploy-k9.msi'; 'MsiExecSwitches' = '/norestart /passive PRE_DEPLOY_DISABLE_VPN=1' }
	@{ 'Title' = 'Cisco AnyConnect Network Access Manager'; 'Version' = '3.1.05182'; 'Installer' = 'anyconnect-nam-win-3.1.05182-k9.msi' }
	@{ 'Title' = 'Cisco NAC Agent'; 'Version' = '4.9.4.3'; 'Installer' = 'nacagentsetup-win-4.9.4.3.msi'; 'Transforms' = "$WorkingDir\NacAgentShortcutRemoval.mst" }
	@{ 'Title' = 'Cisco AnyConnect Diagnostics and Reporting Tool'; 'Version' = '3.1.05182'; 'Installer' = 'anyconnect-dart-win-3.1.05182-k9.msi' }
)

$SoftwareInstallers | foreach {
	if (!(Test-InstalledSoftware -Name $_.Title -Version $_.Version)) {
		$Params = @{ 'MsiInstallerFilePath' = "$WorkingDir\$($_.Installer)" }
		if ($_.Transforms) {
			$Params.MstFilePath = $_.Transforms
		}
		if ($_.MsiExecSwitches) {
			$Params.MsiExecSwitches = $_.MsiExecSwitches
		}
		Install-Software @Params
	}
}

## Disable connection notices for all users
$null = Set-RegistryValueForAllUsers -RegistryInstance @{ 'Name' = 'EnableStatusPopups'; 'Type' = 'Dword'; 'Value' = '0'; 'Path' = 'SOFTWARE\Cisco\Cisco AnyConnect Secure Mobility Client' }
