#region Demo setup

$demoFolderPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\TechMentor 2016\Building Real PowerShell Tools for Real Ops Tasks\Demos'

#endregion

#region AD Account Automator Tool

#region Installing RSAT

## Install RSAT
Invoke-Item "$demoFolderPath\Windows8.1-KB2693643-x64.msu"

## Enable the Active Directory Module for Windows PowerShell
appwiz.cpl

## Ensure the module is showing up in PowerShell
Get-Module -ListAvailable ActiveDirectory

## Exploring the module
Get-Command -Module ActiveDirectory

## Assuming a Server 2008+ DC with Active Directory Web Services installed
Get-ADUser -Filter *

#endregion

#region Wasting time with ADUC

Invoke-Item "$demoFolderPath\corpstandardrules.png"

dsa.msc

#endregion

#region Onboarding new employees

ise "$demoFolderPath\New-EmployeeOnboardUser.ps1"
ise "$demoFolderPath\New-EmployeeOnboardComputer.ps1"

#endregion

#region Modifying AD User and Computer Attributes

ise "$demoFolderPath\Set-MyAdComputer.ps1"
ise "$demoFolderPath\Set-MyAdUser.ps1"

#endregion

#region Building the Tool Set

ise "$demoFolderPath\AdvancedFunctionShell.ps1"
ise "$demoFolderPath\AdAccountManagementAutomator.ps1"
ise "$demoFolderPath\CsvImportExample.ps1"
ise "$demoFolderPath\Users.csv"

#endregion

#endregion

#region Log Investigator

#region Interrogating Windows Event Logs

ise "$demoFolderPath\Get-WinEventWithin.ps1"

#endregion

#region Interrogating Text Logs

ise "$demoFolderPath\Get-TextLogEventWithin.ps1"

#endregion

#region Building the Tool Set

ise "$demoFolderPath\LogInvestigator.ps1"
ise "$demoFolderPath\Get-InterestingEventsWithinTimeframe.ps1"

#endregion

#endregion

#region File and Folder Managmenent Automator

#region Finding Files and Folders Like a Boss

ise "$demoFolderPath\Get-MyFile.ps1"

#endregion

#region Managing File System ACLs

ise "$demoFolderPath\Get-MyACL.ps1"
ise "$demoFolderPath\Set-MyACL.ps1"
ise "$demoFolderPath\Remove-MyACL.ps1"

#endregion

#region Archiving Old Files

ise "$demoFolderPath\Archive-File.ps1"

#endregion

#region Building the Toolset

ise "$demoFolderPath\FileFolderAutomator.ps1"
ise "$demoFolderPath\ToolsetExample.ps1"

#endregion

#endregion

#region Wrapping up into a module --wingin' it!

#endregion