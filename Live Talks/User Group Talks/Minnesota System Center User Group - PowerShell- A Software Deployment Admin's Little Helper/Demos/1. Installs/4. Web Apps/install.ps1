Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
New-Shortcut -CommonLocation AllUsersDesktop -Name 'Shortcut to Web App' -TargetPath 'http://www.somecompanywebapp.com'
