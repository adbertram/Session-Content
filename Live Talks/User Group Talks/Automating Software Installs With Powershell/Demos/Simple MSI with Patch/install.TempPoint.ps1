Import-Module \\configmanager\deploymentmodules\SoftwareInstallManager
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
Start-Log

Stop-MyProcess 'AcroRd32', 'Acrobat.com', 'Adobe_Updater' -Verbose

Start-Process "$WorkingDir\AdbeArCleaner.exe" -ArgumentList '/silent /product=1' -Wait -NoNewWindow
Get-InstalledSoftware -Name 'Adobe Reader 7.0' -Verbose | Remove-Software -Verbose
Remove-ItemFromAllUserProfiles 'AppData\Local\Adobe\Acrobat', 'AppData\LocalLow\Adobe\Acrobat', 'AppData\Roaming\Acrobat' -Verbose

Install-Software -MsiInstallerFilePath "$WorkingDir\AcroRead.msi" -MstFilePath "$WorkingDir\AcroRead.mst" -MspFilePath "$WorkingDir\AdbeRdrUpd11010.msp" -Verbose