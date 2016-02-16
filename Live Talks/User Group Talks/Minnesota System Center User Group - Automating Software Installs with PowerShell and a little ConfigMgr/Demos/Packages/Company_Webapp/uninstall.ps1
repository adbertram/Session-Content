Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

$WebAppUrl = 'http://www.somecompanywebapp.com'

## Kill all IE instances
Stop-MyProcess -ProcessName 'iexplore'

## Remove all shortcuts with the URL
Get-Shortcut -MatchingTargetPath $WebAppUrl | Remove-Item -Confirm:$false
