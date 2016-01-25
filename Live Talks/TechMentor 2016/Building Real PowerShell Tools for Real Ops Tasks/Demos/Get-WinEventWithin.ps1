param([string]$ComputerName = 'localhost',[datetime]$StartTimestamp,[datetime]$EndTimestamp)

$Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | where { $_.RecordCount }).LogName
$FilterTable = @{
	'StartTime' = $StartTimestamp
	'EndTime' = $EndTimestamp
	'LogName' = $Logs
}
		
Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterTable -ErrorAction 'SilentlyContinue'