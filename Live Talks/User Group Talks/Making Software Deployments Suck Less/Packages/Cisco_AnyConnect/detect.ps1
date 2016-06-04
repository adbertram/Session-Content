Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

## Check if all software was installed
$SoftwareToValidate = @(
	@{ 'Title' = 'Cisco AnyConnect Diagnostics and Reporting Tool'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Network Access Manager'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Secure Mobility Client';  'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco NAC Agent';  'Version' = '4.9.4.3' }
)
foreach ($Title in $SoftwareToValidate) {
	if (!(Test-InstalledSoftware -Name $Title.Title -Version $Title.Version)) {
		Write-Log -Message "The software [$($Title.Title)] - Version [$($Title.Version)] does not exist."
		exit
	}
}

$WinXpPath = "$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco AnyConnect Secure Mobility Client\Network Access Manager\system\configuration.xml"
$Win7Path = "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco AnyConnect Secure Mobility Client\Network Access Manager\system\configuration.xml"
if (Test-Path $WinXPPath) {
	$LocalConfFile = Get-Content $WinXpPath
} elseif (Test-Path $Win7Path) {
	$LocalConfFile = Get-Content $Win7Path
} else {
	Write-Log -Message 'Could not find the appropriate configuration file.' -LogLevel 3
	exit
}

## Check if the connection notices were disabled for the current user
## This isn't a thorough check because the installer disables for all users but it's close
New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
$LoggedOnSids = Get-LoggedOnUserSID
foreach ($sid in $LoggedOnSids) {
	try {
		$Popups = Get-ItemProperty -Path "HKU:\$sid\SOFTWARE\Cisco\Cisco AnyConnect Secure Mobility Client" -Name 'EnableStatusPopups'
		if ($Popups -and ($Popups.EnableStatusPopups -ne '0')) {
			Write-Log -Message "The property [$($Popups)] does not equal 0." -LogLevel 3
			exit
		}
	} catch {
		Write-Log -Message $_.Exception.Message -LogLevel 3
		exit
	}
}
$true