<# Problems
1. No help
2. No advanced function
3. No parameters for the module.
4. No validation --too many assumptions
5. No logging
6. No error handling
#>

Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
Set-Location CAS:
Write-Output "Gathering list of WKIDs..."
$wkids = Get-CMDevice -CollectionName "OSD Masters" | Select-Object -ExpandProperty Name
Set-Location C:\
$dumps = @()

Write-Output "Checking WKIDs for .dmp files..."
foreach ($wkid in $wkids) {
    $dumps += Get-ChildItem \\$wkid\c$\programdata\1e\pxelite\*.dmp | select Fullname,LastWriteTime
    #Copy-Item $dump C:\users\dxr5354a\Desktop\PXEdumps\$wkid-PXELiteServer.dmp -Verbose
}

$dumps | sort -Descending LastWriteTime