## Save our test client into a variable in case we need to test against something else later
$ComputerName = 'CLIENT1'

#region REQUIREMENT 1 - Allow helpdesk to query any event log by name

## Look through available cmdlets to figure out how to query event logs
Get-Command -Name *eventlog*

## I see event log names but a bunch of other stuff though
Get-EventLog -ComputerName $ComputerName -LogName *

## Only get the event log names. This will allow us to populate a list for helpdesk to choose from
(Get-EventLog -ComputerName $ComputerName -LogName *).Log

#endregion

#region REQUIREMENT 2 - Allow helpdesk to pick between either errors or warning events

## Figure out a way to filter on warning events or error events
Get-Help Get-EventLog -Detailed

## Helpdesk only needs warning and error events so our valid values look to be 'Error' and 'Warning'
## Pick one of the log names we were able to pull above just to test this out. We can fill in the log name later in the GUI

## I only need warnings
Get-EventLog -ComputerName $ComputerName -LogName Application -EntryType Warning

## I only need errors
Get-EventLog -ComputerName $ComputerName -LogName System -EntryType Error

#endregion

#region REQUIREMENT 3 - Allow helpdesk to pick events within the last hour or last day

## Figure out how to limit events by timeframe: last day --first determine how to get 1 day ago
Get-Date
Get-Date | Get-Member

## It does get 24 hours ahead
(Get-Date).AddDays(1)

## How about the other way?
(Get-Date).AddDays(-1)

## Do the same for hours
(Get-Date).AddHours(-1)

## now incorporate this code into the filter for Get-EventLog
$1DayAgo = (Get-Date).AddDays(-1)
$1HourAgo = (Get-Date).AddHours(-1)

Get-EventLog -ComputerName $ComputerName -LogName Application -After $1DayAgo
Get-EventLog -ComputerName $ComputerName -LogName System -After $1HourAgo

#endregion

#region REQUIREMENT 4 - Helpdesk only needs to see the time the event was generated and the message

## Simply send a sample output of Get-EventLog to two properties
Get-EventLog -ComputerName $ComputerName -LogName Application | select timegenerated, message

#endregion