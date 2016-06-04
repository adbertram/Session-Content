Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log

New-Shortcut -CommonLocation AllUsersDesktop -Name 'Company Web App' -TargetPath 'http://www.somecompanywebapp.com'
