<#
    .SYNOPSIS 
    Check load time of Citrix profiles and total connected users
    
    .DESCRIPTION
    This script queries \\server01\citrixprofiles\CTXRoam to determine load time to browse the share. 
    If the load time is greater than 60 seconds, the email shows ATTENTION NEEDED. 
    This script also queries http://server02/xenapp/new_asof65.aspx to get the list of current users on the Citrix servers. 

    Author: Daniel Ratliff, Client Innovation Technologies
    Date: 2/18/2014
    
    .INPUTS
    None. You cannot pipe objects to Citrix_Profile_Performance.ps1.

    .OUTPUTS
    This script emails a specified list of users/distribution lists with the results of the run. 

    .EXAMPLE
    C:\PS> .\Citrix_Profile_Performance.ps1 -EmailTarget Citrix

    .EXAMPLE
    C:\PS> .\Citrix_Profile_Performance.ps1 -EmailTarget EntireGroup
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Citrix","EntireGroup")]
    $emailtarget
)

# Parse share for response time
$share = "\\server01\citrixprofiles\CTXRoam"

$loadtime = (Measure-Command -Expression {(Get-ChildItem $share)}).TotalSeconds
write-host "Load Time:"$loadtime

# Parse web site for total connected users
$site = "http://server02/xenapp/new_asof65.aspx"

$usage = (((Invoke-WebRequest $site -TimeoutSec 60).Content).substring(2255,5)).replace("&","")

# Send email with profile response time and total profiles
$day = get-date -UFormat '%m/%d'

#Determine recipients, set appropriate time, and email recipients
if ($emailtarget -eq "Citrix" -and $loadtime -gt 60) {
    $to = "user01@gmail.com", "group01@gmail.com"
    $cc = "user02@gmail.com"
    $time = get-date -UFormat '%I:%M%p'
    $subject = "Citrix Profiles - $day - $time update - ATTENTION NEEDED"
    $loadmsg = "Citrix profiles are enumerating slowly.`nATTENTION NEEDED"
$body = @"
$loadmsg
Currently have $usage users connected!
"@
    $from = 'groups02@gmail.com'
    Send-MailMessage -SmtpServer pobox.humana.com -Subject $subject -Body $body -From $from -To $to -Cc $cc -Verbose

} elseif ($emailtarget -eq "EntireGroup") {

    $to = "user01@gmail.com", "group01@gmail.com"
    $cc = "user02@gmail.com"
    $time = get-date -UFormat '%I%p'
    if ($loadtime -gt 60) {
        $subject = "Citrix Profiles - $day - $time update - ATTENTION NEEDED"
        $loadmsg = "Citrix profiles are enumerating slowly.`nATTENTION NEEDED"
    } else {
        $subject = "Citrix Profiles - $day - $time update"
        $loadmsg = "Citrix profiles are enumerating quickly.`nNo issues reported."
    }
    
    $body = @"
$loadmsg
Currently have $usage users connected!
"@

    $from = 'groups02@gmail.com'

    Send-MailMessage -SmtpServer pobox.domain.com -Subject $subject -Body $body -From $from -To $to -Cc $cc -Verbose
}