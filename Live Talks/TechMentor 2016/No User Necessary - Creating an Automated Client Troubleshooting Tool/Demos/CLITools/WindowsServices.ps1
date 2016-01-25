## Save our test client into a variable in case we need to test against something else later
$ComputerName = 'CLIENT1'

#region REQUIREMENT 1 - Allow helpdesk to see all Windows services

Get-Service -ComputerName $ComputerName | select *

## Get ALL properties just for investigation
$services = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName -Property * | select *

#endregion

#region REQUIREMENT 2 - Allow helpdesk to only see disabled services

## Using StartMode I get what I want. I'm selecting name and startmode just to eyeball the results
$services | where {$_.StartMode -eq 'Disabled'} | select displayname,startmode

#endregion

#region REQUIREMENT 3 - Allow helpdesk to only see stopped services

$services | where { $_.State -eq 'Stopped' } | select displayname, startmode

#endregion

#region REQUIREMENT 4 - Allow helpdesk to enable a service that is disabled

Get-Service -ComputerName $ComputerName -DisplayName 'ASP.NET State Service' | Set-Service -StartupType Automatic

#endregion

#region REQUIREMENT 5 - Allow helpdesk to start a service

Get-Service -ComputerName $ComputerName -DisplayName 'asp.net state service' | Start-Service

#endregion