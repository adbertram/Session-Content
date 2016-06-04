#region Demo prep

## Run as administrator
Get-Process 'chrome','iexplore' -ea Ignore | Stop-Process
Set-ExecutionPolicy -ExecutionPolicy Restricted -Force

#endregion

#region Download and install PowerCLI

## Run the installer
& C:\VMware-PowerCLI-6.3.0-3737840.exe
#endregion

#region Set the execution policy from Restricted (if set that way)
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Get-ExecutionPolicy
#endregion

#region Starting PowerCLI
# 1. The different console
Invoke-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\VMware'

## Or just use your own session

#endregion

## Show all modules
Get-Module -Name vmware.vimautomation.* -ListAvailable

## Common commands in module
Get-Command -Module VMware.VimAutomation.Core

## Everything is an "object" associated with various verbs
Get-Command -Module vmware.vimautomation.core | sort noun | select verb,noun

#region Investigate the Connect-ViServer cmdlet
Get-Command -Module VMware.VimAutomation.Core -Name 'Connect-ViServer'
Get-help -Name 'Connect-ViServer'
Get-help -Name 'Connect-ViServer' -Examples
#endregion

#region Make the connection to the vCenter server

Connect-VIServer -Server vcenter -Credential (Get-Credential)
Connect-VIServer -Server vcenter -User 'root' -Password 'p@$$w0rd12'

#endregion

#region First phase of poking around --the Get* cmdlets
Get-Command -Module VMware.VimAutomation.Core -Verb Get
Get-VM
Get-VM -Name MYVM
#endregion

#region "Gluing" commands together with the pipeline

Get-VM -Name MYVM | Start-VM

#endregion

#region Building a tool

## Getting the VMs but not the properties we need
$vms = Get-VM

## Few properties displayed. These aren't ALL the properties
$vms

## Here are all properties but no uptime, boottime, etc
$vms | Get-Member | Select-Object Name | Sort-Object Name

## Need to pass the VM objects to Get-View to get more information
$vms = Get-VM | Get-View

## We only need runtime but that doesn't look too good. bootTime is a property of runtime. need to dig deeper
$vms | select runtime

## Enumerate boottime
$vms | ForEach-Object { $_.runtime.boottime} 

## We need to do some date/time math to subtract Now from the boottime
## This is NOT using PowerCLI but native PowerShell to manipulate what Get-View is returning
$vms | Select-Object Name, @{ Name = "UptimeDays"; Expression = { (New-TimeSpan -Start $_.Runtime.BootTime -End (Get-Date)).Days } }
#endregion