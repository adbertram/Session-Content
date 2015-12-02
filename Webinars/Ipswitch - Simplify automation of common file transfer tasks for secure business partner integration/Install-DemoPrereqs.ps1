## For the demonstration to work correctly several pieces of software need to be loaded onto the MOVEit Central server
## to work properly.  This script will download and install all of them.

#region Download and install all prereqs

## All required installers and the URLs they are located at
$files = [ordered]@{
	'SQLSysClrTypes.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409' # Microsoft® System CLR Types for Microsoft® SQL Server® 2012 (x64)
	'SharedManagementObjects.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239659&clcid=0x409' # Microsoft® SQL Server® 2012 Shared Management Objects (x64)
	'PowerShellTools.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239656&clcid=0x409' # Microsoft® Windows PowerShell Extensions for Microsoft® SQL Server® 2012 (x64)
	'azure-powershell.0.9.8.msi' = 'https://github.com/Azure/azure-powershell/releases/download/v0.9.8-September2015/azure-powershell.0.9.8.msi' # Azure PowerShell module
}

#region Create the download folder
$downloadFolder = 'C:\IpswitchDemo'
if (-not (Test-Path -Path $downloadFolder -PathType Container))
{
	$null = mkdir -Path $downloadFolder
}
#endregion

#region Download each file and, if an installer, then execute it silently with msiexec.exe
foreach ($file in $files.GetEnumerator())
{
	$downloadFile = (Join-Path -Path $downloadFolder -ChildPath $file.Key)
	Invoke-WebRequest -Uri $file.Value -OutFile $downloadFile
	if ([System.IO.Path]::GetExtension($downloadFile) -eq '.msi')
	{
		Start-Process -FilePath 'msiexec.exe' -Args "/i $downloadFile /qn" -Wait
	}
}
#endregion

#region Modify the module path to ensure that the Azure service managment and sql ps module will auto-load

$paths = $env:PSModulePath -split ';'
$paths += 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement', 'C:\Program Files\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS'
$modulePath = $paths -join ';'

$env:PSModulePath = $modulePath

#endregion

## Connect to your subscription
Add-AzureAccount ## The data collection 60 second will be fixed in the Azure PowerShell module 1.0

#region Open firewall rule to server
## https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query/

## Get your Azure SQL server name --I only have a single server here so I'll be using that one.
$azSqlServer = Get-AzureSqlDatabaseServer

## Get your client's public IP --can always to a block range if you'd like.
$ipAddress = (Invoke-WebRequest 'http://myexternalip.com/raw').Content -replace "`n"

## Create the firewall rule
New-AzureSqlDatabaseServerFirewallRule -ServerName $azSqlServer.ServerName -RuleName 'ClientRule' -StartIpAddress $ipAddress -EndIpAddress $ipAddress

#endregion