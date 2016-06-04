param(
$days
)

$path = "\\server01\osd\logs"
$day = (get-date -day 1) - (New-TimeSpan -days $days)
$logs = Get-ChildItem -Path $path | Where-Object {$_.Lastwritetime -lt $day}
Write-host "Log folders:"$logs.Count

write-warning "This script removes all logs from $path before $day!"
write-host "Are you sure you want to continue?" -ForegroundColor Yellow
$continue = read-host -Prompt "Press Y to continue"

if ($continue -eq "Y") {
    ForEach ($logfolder in $logs) {
        write-host "Removing: "$logfolder.FullName
        Remove-Item $logfolder.FullName -Recurse -Force
    }
}