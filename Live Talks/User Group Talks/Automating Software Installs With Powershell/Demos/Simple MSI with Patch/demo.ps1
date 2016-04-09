Import-Module ..\Modules\SoftwareInstallManager.psm1 -DisableNameChecking

Get-InstalledSoftwareInRegistry -Name 'Adobe*'

## Let's check the log file generated
## Use the module's function to get the Windows temp folder
Get-SystemTempFolderPath

## Look at the log generated
Import-Csv -Path "$(Get-SystemTempFolderPath)\SoftwareInstalledByPowershell.log"