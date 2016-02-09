Import-Module \\configmanager\deploymentmodules\SoftwareInstallManager -DisableNameChecking
Start-Log

## Check if all software was installed
$SoftwareToValidate = @(
	@{ 'Title' = 'Cisco AnyConnect Diagnostics and Reporting Tool'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Network Access Manager'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Secure Mobility Client';  'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco NAC Agent';  'Version' = '4.9.4.3' }
)
foreach ($Title in $SoftwareToValidate) {
	if (!(Validate-IsSoftwareInstalled -ProductName $Title.Title -Version $Title.Version)) {
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
	exit
}
$PackageConfFile = Get-Content '\\hosp.uhhg.org\dfs\softwarelibrary\software_packages\Cisco_AnyConnect_3.1.05182\configuration.xml'
if (($LocalConfFile -join '|') -ne ($PackageConfFile -join '|')) {
	exit
}

## Check if the other configuration file got copied properly
$InstallLocation = Get-InstallLocation -ProductName 'Cisco NAC Agent'
if (!(Test-Path "$InstallLocation\NACAgentCFG.xml")) {
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
			exit
		}
	} catch {
		exit
	}
}
$true