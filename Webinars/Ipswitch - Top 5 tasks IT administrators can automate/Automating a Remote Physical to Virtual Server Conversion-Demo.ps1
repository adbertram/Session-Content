## GOAL: To remotely convert physical disks to VHDs and transfer back to a remote location.

#region Demo setup
$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\Ipswitch - Top 5 tasks IT administrators can automate'

Add-Content -Path '\\MEMBERSRV1\c$\MEMBERSRV1.vhd' -Value '' -ea SilentlyContinue

#endregion

## Dot source the function so it's available in the session

. "$demoPath\Automating a Remote Physical to Virtual Server Conversion.ps1"

<#
	## Review function steps
	1. Verify the c$ share and PowerShell remoting is available.
	2. Copy the disk2vhd.exe file to the remote computer.
	3. Run disk2vhd.exe on the remote computer converting all volumes to VHD files.
	## MoveIt will take over the VHD file
#>

## Review the function

ise "$demoPath\Automating a Remote Physical to Virtual Server Conversion.ps1"

## Run the function

Convert-PhysicalDiskVolume -ComputerName MEMBERSRV1 -DestinationFolderPath '\\membersrv1\c$\VHDs' -Verbose