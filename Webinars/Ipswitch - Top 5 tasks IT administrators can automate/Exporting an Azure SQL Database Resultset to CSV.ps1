## GOAL: The query an Azure SQL database and convert the result into a CSV file

#Requires -Version 4

$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\Ipswitch - Top 5 tasks IT administrators can automate'

#region Download and install all prereqs

$files = [ordered]@{
	'SQLSysClrTypes.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409' # Microsoft® System CLR Types for Microsoft® SQL Server® 2012 (x64)
	'SharedManagementObjects.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239659&clcid=0x409' # Microsoft® SQL Server® 2012 Shared Management Objects (x64)
	'PowerShellTools.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239656&clcid=0x409' # Microsoft® Windows PowerShell Extensions for Microsoft® SQL Server® 2012 (x64)
}

$downloadFolder = 'C:\AzureSql'
if (-not (Test-Path -Path $downloadFolder -PathType Container))
{
	$null = mkdir -Path $downloadFolder
}
foreach ($file in $files.GetEnumerator())
{
	$downloadFile = (Join-Path -Path $downloadFolder -ChildPath $file.Key)
	Invoke-WebRequest -Uri $file.Value -OutFile $downloadFile
	if ([System.IO.Path]::GetExtension($downloadFile) -eq '.msi')
	{
		Start-Process -FilePath 'msiexec.exe' -Args "/i $downloadFile /qn" -Wait
	}
}

## Requires PowerShellGet (included in PSv5)
Find-Module Azure
Find-Module Azure | Install-Module

## Modify the module path to ensure that the Azure service managment and sql ps module will auto-load
$paths = $env:PSModulePath -split ';'
$paths += 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement', 'C:\Program Files\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS'
$modulePath = $paths -join ';'

$env:PSModulePath = $modulePath

#endregion

## Connect to your subscription
Add-AzureAccount

#region Open firewall rule to server
## https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query/

## Get your Azure SQL server name --I only have a single server here so I'll be using that one.
$azSqlServer = Get-AzureRmSqlServer -ResourceGroupName adbdemoresourcegroup

## Get your client's public IP --can always to a block range if you'd like.
$ipAddress = (Invoke-WebRequest 'http://myexternalip.com/raw').Content -replace "`n"

## Create the firewall rule
New-AzureRmSqlServerFirewallRule -ServerName $azSqlServer.ServerName -FirewallRuleName 'ClientRuleIpswitch' -StartIpAddress $ipAddress -EndIpAddress $ipAddress -ResourceGroupName adbdemoresourcegroup

#endregion

#region Save your credential to the file system encrypted for reuse

$Credential = Get-Credential
$Credential | Export-CliXml -Path "$demoPath\Credential.xml"

## This will create a XML file with the credentials encrypted. Then, to use it, you can use Import-CliXml like this:

$cred = Import-CliXml -Path "$demoPath\Credential.xml"

#endregion

$username = $cred.Username
$password = $cred.GetNetworkCredential().Password

#region Query the Customer SQL table
$params = @{
	'Database' = 'myazuredatabase'
	'ServerInstance' = "$($azSqlServer.ServerName).database.windows.net"
	'Username' = $username
	'Password' = $password
	'OutputSqlErrors' = $true
	'Query' = 'SELECT * FROM SalesLT.Customer'
}
$result = Invoke-Sqlcmd @params | select -First 10
$result

#endregion

## Convert the result set to CSV

$result | Export-Csv "$demoPath\Customers.csv"
Import-Csv -Path "$demoPath\Customers.csv"