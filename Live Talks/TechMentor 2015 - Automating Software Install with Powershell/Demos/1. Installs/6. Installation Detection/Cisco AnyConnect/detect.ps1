Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
$SoftwareToValidate = @(
	@{ 'Title' = 'Cisco AnyConnect Diagnostics and Reporting Tool'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Network Access Manager'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Secure Mobility Client';  'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco NAC Agent';  'Version' = '4.9.4.3' }
)
foreach ($Title in $SoftwareToValidate) {
	if (-not (Test-InstalledSoftware -Name $Title.Title -Version $Title.Version)) {
		Write-Host -Message "$($Title.Title) is not installed" -ForegroundColor Red
	} else {
		Write-Host -Message "$($Title.Title) is installed" -ForegroundColor Green
	}
}

## Check if the connection notices were disabled for the current user
Write-Log -Message 'Checking to ensure the connection notices were disabled'
New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
$LoggedOnSids = Get-LoggedOnUserSID
foreach ($sid in $LoggedOnSids) {
	try {
		Write-Log -Message "Checking SID $sid..."
		$Popups = Get-ItemProperty -Path "HKU:\$sid\SOFTWARE\Cisco\Cisco AnyConnect Secure Mobility Client" -Name 'EnableStatusPopups' -ErrorAction SilentlyContinue
		if ($Popups -and ($Popups.EnableStatusPopups -ne '0')) {
			Write-Host "The user profile SID $sid connection notices was not changed" -ForegroundColor Red
			exit
		} else {
			Write-Host "The user profile SID $sid connection notices was successfully changed" -ForegroundColor Green
		}
	} catch {
		Write-Log -Message $_.Exception.Message -LogLevel 3
		exit
	}
}
