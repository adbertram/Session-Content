Import-Module ..\Modules\SoftwareInstallManager.psm1 -DisableNameChecking
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
Start-Log

$Params = @{
	'MsiInstallerFilePath' = "$WorkingDir\AcroRead.msi"
	'MspFilePath' = "$WorkingDir\AdbeRdrUpd11010.msp"
	'MstFilePath' = "$WorkingDir\AcroRead.mst"
	'KillProcess' = 'AcroRd32', 'Acrobat.com', 'Adobe_Updater'
}

Install-Software @Params