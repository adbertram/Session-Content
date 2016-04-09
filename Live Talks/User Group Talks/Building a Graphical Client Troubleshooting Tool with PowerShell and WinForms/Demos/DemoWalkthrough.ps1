#region Demo prep
$DemoFolderPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\User Group Talks\Central Texas PowerShell User Group - Building a Graphical Client Troubleshooting Tool with PowerShell and WinForms\Demos'
$ComputerName = 'CLIENT1'
$ServerName = 'MEMBERSRV1'

if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1) {
    throw "Client [$ComputerName] is not pingable."
}

if (Test-Connection -ComputerName $ServerName -Quiet -Count 1) {
    throw "Server [$ServerName] is not pingable."
}

if ((Invoke-Command -ComputerName $ComputerName -ScriptBlock {hostname}) -ne $ComputerName) {
    throw "Client [$ComputerName] cannot be remoted to."
}

if ((Invoke-Command -ComputerName $ServerName -ScriptBlock {hostname}) -ne $ServerName) {
    throw "Server [$ServerName] cannot be remoted to."
}

#endregion

#region PowerShell Studio Quick Overview

#endregion

#region Core Tool Functionality

#region Querying installed updates

## REQUIREMENTS Show description and KB number of all installed updates

## Very easy. Not much code needed at all here but keep the modularity always
Invoke-Item "$DemoFolderPath\CLITools\InstalledUpdates.ps1"

#endregion

#region Event logs

## REQUIREMENTS Allow helpdesk to look at errors or warning events in any one event log by name within the last hour or day
## Helpdesk only needs to see the time the event was generated and the message

## More involved --must separate out individual components
Invoke-Item "$DemoFolderPath\CLITools\EventLogs.ps1"

#endregion

#region Windows services

## REQUIREMENTS Helpdesk needs to quickly be able to find all disabled and stopped services and be able to briefly scan down
## through all the services if they want to. They need to see service name, if it's running or not and what it's startup type is.
## They also need to be able to start and enable a service.

Invoke-Item "$DemoFolderPath\CLITools\WindowsServices.ps1"

#endregion

#region VNC Deployment and Quick Access

## REQUIREMENTS Need to see if VNC is installed. If not, need a quick way to remotely deploy it

## Check to see if VNC is installed on the remote client
Invoke-Item "$DemoFolderPath\CLITools\VNC\Test-VNCInstalled.ps1"

#region Prepping for the VNC functionality --One time only

## Create a file share on a remote server for the tool to pull UltraVNC binaries from
$toolSharePath = "\\$ServerName\c$\ToolShare"
mkdir $toolSharePath
Invoke-Command -ComputerName $ServerName -Scriptblock { New-SmbShare -Name ToolShare -Path 'C:\ToolShare' }

## Creating the INF file to build our "answer" file to silently install VNC
$localVncInstallerFolder = "$DemoFolderPath\VNC"

## Already created INF file
#& "$localVncInstallerFolder\UltraVNC_Setup.exe" /saveinf="$localVncInstallerFolder\UltraVNCSilentInstall.inf"

## Copy the INF and installer file to the file share
copy -Path $localVncInstallerFolder -Destination $toolSharePath -Recurse

## The file share contents
Get-ChildItem -Path $toolSharePath

#endregion

## Build functionality to allow quick VNC viewer access
Invoke-Item "$DemoFolderPath\CLITools\VNC\View-VNC.ps1"

## Build functionality to remotely deploy VNC (if needed)
## This is fairly complicated and was created with lots of trial and error. Not really going over specifics here.
Invoke-Item "$DemoFolderPath\CLITools\VNC\Deploy-VNC.ps1"

#endregion

#endregion

#region Building the GUI

#region Demonstrate existing project

## Open the PowerShell Studio project

Invoke-Item "$DemoFolderPath\GUI\HelpdeskTool.psproj"

## Explain PowerShell Studio's default project files and how I'm using them

ii "$DemoFolderPath\GUI\Globals.ps1"
ii "$DemoFolderPath\GUI\Startup.pss"

## Open up the main form of the existing project

ii "$DemoFolderPath\GUI\MainForm.psf"

#endregion

#endregion