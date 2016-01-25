<#
.SYNOPSIS
    This script finds all Windows events in all event logs and all log files on a local or remote machine
    recorded within a specific timeframe		
.EXAMPLE
	PS> Get-InterestingEventsWithinTimeframe.ps1 -Computername MYCOMPUTER -StartTimestamp '04-15-15 04:00' -EndTimestamp '04-15-15 08:00' -LogFileExtension 'log'

    This example finds all events and .log files on all drives on the remote computer MYCOMPUTER from April 15th, 2015 at 4AM to April 15th, 2015 at 8AM.
.PARAMETER Computername
    The computer name you'd like to search for text and event logs on.  This defaults to localhost.
.PARAMETER StartTimestamp
    The earliest last write time of a log file and earliest time generated on an event you'd like to find
.PARAMETER EndTimestamp
    The latest last write time of a log file and latest time generated on an event you'd like to find
.PARAMETER LogFileExtension
    When searching log files, this is file extension you will be limiting your search to. This defaults to 'log'
#>
[CmdletBinding()]
param (
    [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
    [string]$Computername = 'localhost',
    [Parameter(Mandatory)]
    [datetime]$StartTimestamp,
    [Parameter(Mandatory)]
    [datetime]$EndTimestamp,
    [string]$LogFileExtension = 'log'
)
begin {
    . C:\LogInvestigator.ps1
}
process {
	try {
        $Params = @{
            'Computername' = $Computername
            'StartTimestamp' = $StartTimestamp
            'EndTimestamp' = $EndTimestamp
        }
        Get-WinEventWithin @Params
	    Get-TextLogEventWithin @Params -LogFileExtension $LogFileExtension
	} catch {
		Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	}
}