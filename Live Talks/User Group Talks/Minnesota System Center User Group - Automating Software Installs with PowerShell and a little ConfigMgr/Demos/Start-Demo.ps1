#region Demo setup

$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\User Group Talks\Minnesota System Center User Group - Automating Software Installs with PowerShell and a little ConfigMgr\Demos'

#endregion

## Local SoftwareInstallMnaager module review

## functions demo (quick)
ipmo  "$demoPath\Packages\SoftwareInstallManager"

gcm -Module SoftwareInstallManager
Get-InstalledSoftware
Get-UserProfile | select username, profileimagepath
Get-SystemTempFolderPath

## SoftwareInstallManager overview
ii "$demoPath\Packages\SoftwareInstallManager\SoftwareInstallManager.psm1"

## Build new apps with PowerShell module in mind and in a standardized way

ii "$demoPath\New-CMMyApplication.ps1"
## Run on SCCM: 
# C:\New-CMMyApplication.ps1 -Name MyApp -Manufacturer 'Microsoft' -SoftwareVersion '1.0' -SourceFolderPath '\\membersrv1\Packages\Company_Webapp' -Verbose

## Show detect/install/uninstall scripts created

## Run available deployments on CLIENT1 and CLIENT2 via Softare Center

## Show logs

## Show each detect/install/uninstall script

