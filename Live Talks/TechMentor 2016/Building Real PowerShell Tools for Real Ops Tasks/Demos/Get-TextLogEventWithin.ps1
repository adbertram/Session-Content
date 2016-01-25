param([string]$ComputerName = 'localhost',[datetime]$StartTimestamp,[datetime]$EndTimestamp,[string]$LogFileExtension = 'log')

## Define the drives to look for log files if local or the shares to look for when remote
if ($ComputerName -eq 'localhost') {
    $Locations = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = '3'").DeviceID
} else {
    ## Enumerate all shares
    $Shares = Get-CimInstance -ComputerName $ComputerName -Class Win32_Share | where { $_.Path -match '^\w{1}:\\$' }
    [System.Collections.ArrayList]$Locations = @()
    foreach ($Share in $Shares) {
	    $Share = "\\$ComputerName\$($Share.Name)"
	    if (!(Test-Path $Share)) {
		    Write-Warning "Unable to access the '$Share' share on '$Computername'"
	    } else {
		    $Locations.Add($Share) | Out-Null	
	    }
    }
}

## Build the hashtable to perform splatting on Get-ChildItem
$GciParams = @{
	Path = $Locations
    Filter = "*.$LogFileExtension"
	Recurse = $true
	Force = $true
	ErrorAction = 'SilentlyContinue'
	File = $true
}

## Build the Where-Object scriptblock on a separate line due to it's length
$WhereFilter = {($_.LastWriteTime -ge $StartTimestamp) -and ($_.LastWriteTime -le $EndTimestamp) -and ($_.Length -ne 0)}

## Find all interesting log files
Get-ChildItem @GciParams | Where-Object $WhereFilter