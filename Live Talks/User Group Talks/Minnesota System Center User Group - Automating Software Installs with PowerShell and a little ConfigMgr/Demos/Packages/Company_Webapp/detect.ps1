Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log

$params = @{
	'MatchingTargetPath' = 'http://www.somecompanywebapp.com/'
	'MatchingName' =  'Company Web App'
	'MatchingFilePath' = 'C:\Users\Public\Desktop'
}
if (Get-Shortcut @params)
{
	$true	
}