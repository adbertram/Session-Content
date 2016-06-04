#region Demo setup

$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\User Group Talks\Making Software Deployments Suck Less'

<<<<<<< HEAD
Invoke-Pester -Path $demoPath
#endregion

#region Example deployment -- I'll go over the details in a minute

## All installer files and pre-created scripts are in a local folder
## This is just the bits to get the software installed

## These could be stored on your admin workstation as well
Get-ChildItem -Path "\\SCCM\Packages\Microsoft_EMET"

## I've already done my testing with the SoftwareInstallManager module functions on my test VM and created my three scripts.
## These are mandatory.
Get-ChildItem -Path "\\SCCM\c$\Packages\Microsoft_EMET" -Filter *.ps1 | ForEach-Object {psedit $_.FullName}

## First we get the SCCM application created and distributed to our DPs
## Run New-CMMyApplication to automate the entire application creation process

#region Don't pay attention to these parameter
## I'm only connecting to the SCCM site server for the demo
## You should probably just run New-CMMyApplication from your admin workstation
$icmParams = @{
	'ComputerName' = 'SCCM'
	'Verbose' = $true
	'Authentication' = 'CredSSP'
	'Credential' = (Get-Credential)
}
#endregion

## 1. Create the SCCM application in a standardized manner
$appParams = @{
	'Name' = 'Enhanced Mitigation Experience Toolkit-Demo'
	'Manufacturer' = 'Microsoft'
	'SoftwareVersion' = '5.5'
	'SourceFolderPath' = 'C:\Packages\Microsoft_EMET'
	'Distribute' = $true
	'Verbose' = $true
}

$icmParams.ScriptBlock = { C:\New-CMMyApplication.ps1 @using:appParams }
Invoke-Command @icmParams

## The script has created the package folder with installer files and template scripts
Get-ChildItem \\MEMBERSRV1\Packages\Microsoft_Enhanced_Mitigation_Experience_Toolkit-Demo_5.5
=======
#endregion

## Local SoftwareInstallMnaager module review
Import-Module  "$demoPath\Packages\SoftwareInstallManager"

Get-Command -Module SoftwareInstallManager
Get-InstalledSoftware
Get-UserProfile | Select-Object username, profileimagepath
Get-SystemTempFolderPath

## Build new apps with PowerShell module in mind and in a standardized way

Invoke-Item "$demoPath\New-CMMyApplication.ps1"
## Run on SCCM: 
# C:\New-CMMyApplication.ps1 -Name MyApp -Manufacturer 'Microsoft' -SoftwareVersion '1.0' -SourceFolderPath '\\membersrv1\Packages\Company_Webapp' -Verbose
>>>>>>> parent of 4ef98ea... updates

## Show what the application looks like in the SCCM console
mstsc /v:SCCM

## Kick off the pre-created Microsoft EMET application already advertised to the clients
mstsc /v:CLIENT1
mstsc /v:CLIENT2

## Show logs in CMTrace format
@('CLIENT1', 'CLIENT2') | foreach { Invoke-Item "\\$_\c$\Windows\Temp\SoftwareInstallManager.log" }

#endregion

#region How the deployment was done

<#
	New-CMMyApplication.ps1
		- Created \\MEMBERSRV1\Packages\<Manufacturer>_<Version> folder
		- Used template.ps1 to create install/uninstall/detec.ps1 scripts in package folder
		- Built a standardized SCCM application filling in all required attributes
		- Distributed package contents to predefined distribution points
	Client deployment
		- Imported SoftwareInstallManager module from \\MEMBERSRV1\Packages\SoftwareInstallManager
		- Ran Install-Software, Test-InstalledSoftware, etc rather than figuring out installer syntax and logged all activity
		- Target application to clients and away you go!
#>

#region The New-CMMyApplication script --server-side automation
psedit "$demoPath\New-CMMyApplication.ps1"

#endregion

## The SoftwareInstallManager module --client-side automation
Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Get-Command -Module SoftwareInstallManager

#endregion