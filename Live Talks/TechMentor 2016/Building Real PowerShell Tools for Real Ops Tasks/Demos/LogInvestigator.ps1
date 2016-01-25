function Get-WinEventWithin {
	<#
	.SYNOPSIS
	    This function finds all events in all event logs on a local or remote computer between a start and end time	
	.EXAMPLE
		PS> Get-WinEventWithin -StartTimestamp '04-15-15 04:00' -EndTimestamp '04-15-15 08:00'

        This example finds all events in all event logs from April 15th, 2015 at 4AM to April 15th, 2015 at 8AM.
	.PARAMETER Computername
        The computer in which you'd like to find event log entries on.  If this is not specified, it will default to localhost.
	.PARAMETER StartTimestamp
        The earlier time of the event you'd like to find an event 
	.PARAMETER EndTimestamp
        The latest time of the event you'd like to find 
	#>
	[CmdletBinding()]
	param (
        [string]$Computername = 'localhost',
        [Parameter(Mandatory)]
        [datetime]$StartTimestamp,
        [Parameter(Mandatory)]
        [datetime]$EndTimestamp
	)
	process {
		try {
            $Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | where { $_.RecordCount }).LogName
            $FilterTable = @{
	            'StartTime' = $StartTimestamp
	            'EndTime' = $EndTimestamp
	            'LogName' = $Logs
            }
		
            Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterTable -ErrorAction 'SilentlyContinue'
		} catch {
			Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
}

function Get-TextLogEventWithin {
	<#
	.SYNOPSIS
	    This function finds all files matching a specified file extension that have a last write time
        between a specific start and end time.
	.EXAMPLE
		PS> Get-TextLogEventWithin -Computername MYCOMPUTER -StartTimestamp '04-15-15 04:00' -EndTimestamp '04-15-15 08:00' -LogFileExtension 'log'

        This example finds all .log files on all drives on the remote computer MYCOMPUTER from April 15th, 2015 at 4AM to April 15th, 2015 at 8AM.
	.PARAMETER Computername
        The computer name you'd like to search for text log on.  This defaults to localhost.
	.PARAMETER StartTimestamp
        The earliest last write time of a log file you'd like to find
	.PARAMETER EndTimestamp
        The latest last write time of a log file you'd like to find
    .PARAMETER LogFileExtension
        The file extension you will be limiting your search to. This defaults to 'log'
	#>
	[CmdletBinding()]
	param (
        [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
        [string]$Computername = 'localhost',
        [Parameter(Mandatory)]
        [datetime]$StartTimestamp,
        [Parameter(Mandatory)]
        [datetime]$EndTimestamp,
        [ValidateSet('txt','log')]
        [string]$LogFileExtension = 'log'
	)
	process {
		try {
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
		} catch {
			Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
}