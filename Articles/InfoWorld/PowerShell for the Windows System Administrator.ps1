#region Event log querying
## Event log single server query
Get-WinEvent -FilterHashtable @{LogName = 'System'; ID = 6005} -ComputerName labdc.lab.local

## Querying event logs across multiple servers
$Servers = Get-Content -Path C:\Servers.txt
foreach ($s in $Servers) {
    Get-WinEvent -FilterHashtable @{LogName = 'System'; ID = 6005} -ComputerName $s
}

## Using Select-Object to only get the first object and show all properties
Get-WinEvent -FilterHashtable @{LogName = 'System'; ID = 6005} -ComputerName labdc.lab.local | select -first 1 *

## Getting only event record creation time and server name
 foreach ($s in $Servers) {
    $getWinEventParams = @{
        'FilterHashTable' = @{LogName = 'System'; ID = 6005}
        'ComputerName' = $s
    }
    Get-WinEvent @getWinEventParams | Select-Object TimeCreated,MachineName
} 

## Using calculated properties to define your own property values
 foreach ($s in $Servers) {
    $getWinEventParams = @{
        'FilterHashTable' = @{LogName = 'System'; ID = 6005}
        'ComputerName' = $s
    }
    Get-WinEvent @getWinEventParams | Select TimeCreated,@{n='MachineName';e = {$s}}
} 
#endregion

#region Server Inventory Report
$Servers = (Get-ADForest).GlobalCatalogs

Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName labdc.lab.local -Property *

$Servers = (Get-ADForest).GlobalCatalogs
foreach ($Server in $Servers) {
	$Output = @{'Name' = $Server }
	$Session = New-CimSession -Computername $Server
	if ($Session) {
	    $Output.OperatingSystem = (Get-CimInstance -CimSession $Session -ClassName Win32_OperatingSystem).Caption
	    $Output.Memory = (Get-CimInstance -CimSession $Session -ClassName win32_physicalmemory).Capacity / 1GB
	    $Output.CPU = (Get-CimInstance -CimSession $Session -ClassName win32_processor).name
	    $Output.FreeDiskSpace = (Get-CimInstance -CimSession $Session -ClassName win32_logicaldisk -Filter "DeviceID = 'C:'").FreeDiskSpace / 1GB
	    Remove-CimSession $Session
	    [pscustomobject]$Output
    }
}
#endregion