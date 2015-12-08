<# 

This is a demonstration script used for the IPswitch MOVEit webinar. It is not meant to be used
in your environment directly but is provided as-is to show you examples of how to execute the script
we're demonstrating.

#>

#region Demo setup
$demoFolder = 'C:\IpSwitchDemo'
#endregion

## Show the prereq install script
ise "$demoFolder\Install-DemoPrereqs.ps1"

## Run the script to download and install all prerequisites
& "$demoFolder\Install-DemoPrereqs.ps1"

## Check for the installed software
control appwiz.cpl

## Show the Azure to XML conversion script
ise "$demoFolder\Convert-AzureSQLTableToXml.ps1"

## Run the conversion script. This script will query an Azure SQL database and pull down all rows in a table. 
## It will then convert those rows in XML and finally save the XML as C:\IpswitchDemo\Users.xml to the local computer.

$scriptParameters = @{
	'WarningAction' = 'SilentlyContinue'
	'OutputFilePath' = 'C:\IpSwitchDemo\Users.xml'
	'ServerInstance' = 'adamazuresql.database.windows.net'
	'Database' = 'myazuredatabase'
	'Username' = 'ipswitch'
	'Password' = '$uper$3cure'
	'Query' = 'SELECT * FROM Users'
}
& "$demoFolder\Convert-AzureSQLTableToXml.ps1" @scriptParameters

ise C:\IpswitchDemo\Users.xml