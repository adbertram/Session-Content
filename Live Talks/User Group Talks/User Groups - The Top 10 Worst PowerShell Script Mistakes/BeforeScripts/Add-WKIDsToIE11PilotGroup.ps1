import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
set-location CAS:
Write-Host "Gathering list of machines with IE11 in ConfigMgr..." -ForegroundColor Cyan -BackgroundColor Black
$coll = Get-CMDevice -CollectionName 'Workstations - Internet Explorer 11'
write-host "Total machines found in ConfigMgr: " -NoNewline -ForegroundColor Yellow -BackgroundColor Black
$coll | Measure-Object | Select-Object -ExpandProperty Count
$domainwkids = $coll.Where({$_.Domain -eq 'DOMAIN'}) | select -ExpandProperty Name
write-host "Total DOMAIN machines found in ConfigMgr: " -NoNewline -ForegroundColor Yellow -BackgroundColor Black
$domainwkids | Measure-Object | Select-Object -ExpandProperty Count

Set-Location c:
Write-Host "Gathering list of machines in G_IE11_UAT_PILOT AD group..." -ForegroundColor Cyan -BackgroundColor Black
$group = Get-ADGroupMember -Identity "G_IE11_UAT_PILOT" -Partition 'DC=domain,DC=com' -Recursive
write-host "Total machines found in AD: " -NoNewline -ForegroundColor Yellow -BackgroundColor Black
$group | Measure-Object | Select-Object -ExpandProperty Count

foreach ($wkid in $domainwkids) {
    if ($wkid -notin $group.name) {
        $wkid
        $adwkid = Get-ADComputer -Identity $wkid
        Add-ADGroupMember -Identity  "G_IE11_UAT_PILOT" -Members $adwkid -ErrorAction SilentlyContinue -Verbose
    }
}