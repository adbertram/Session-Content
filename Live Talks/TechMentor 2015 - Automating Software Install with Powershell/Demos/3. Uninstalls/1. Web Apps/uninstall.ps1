Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
$WebAppUrl = 'http://www.somecompanywebapp.com'

## Kill all IE instances
Stop-MyProcess -ProcessName 'iexplore'

## Remove all shortcuts with the URL
Get-Shortcut -MatchingTargetPath $WebAppUrl | Remove-Item -Confirm:$false
