q#region Intro
$SomeTextFile = 'C:\TextFile.txt'

## Create a new text file
$NewFile = New-Item -Path $SomeTextFile -Type File

## Add stuff to the text file
Add-Content -Path $SomeTextFile -Value 'some value here'
'pipeline input' | Add-Content -Path $SomeTextFile

## Read the text file and output an array (one element per line)
Get-Content -Path $SomeTextFile

## Service manipulation
Get-Service -Name wuauserv | Restart-Service
Get-Service -Name wuauserv -ComputerName localhost | Stop-Service

## Everything's an object
'this is a string' | Get-Member

## man doens't hold a candle to Get-Help
Get-Help Get-Content
Update-Help
#endregion

#region Bash vs. PowerShell

#region Jobs
Start-Job -ScriptBlock { hostname }
Get-Job
Get-Job | Receive-Job
Invoke-Command -scriptBlock { hostname } -computerName $ComputerName -AsJob
#endregion

## tcpdump
#http://www.adamtheautomator.com/start-and-stop-a-packet-capture-from-powershell/

## diff
0..10 | foreach { Add-Content -Path C:\File1.txt -Value $_ }
0..9 | % { Add-Content -Path C:\File2.txt -Value $_ }
Compare-Object (Get-Content C:\File1.txt) (Get-Content C:\File2.txt)

## file copies
Copy-Item C:\File1.txt \\host1\c$
## There's no builtin way to use SCP although community modules have been built that can be imported to do this: https://github.com/dotps1/WinSCP
	
## curl
curl http://www.google.com
Invoke-WebRequest -Uri http://www.google.com

## nmap
#http://www.adamtheautomator.com/one-server-port-testing-tool/

## port status
Get-NetTCPConnection -State Listen

## tar
mkdir C:\FolderTest
0..10 | % { New-Item -Path "C:\FolderTest\$($_).txt" -Value 'testtest' }
Compress-Archive -Path C:\FolderTest -DestinationPath C:\FolderTestZip.zip

## tail
Get-Content -Path c:\Logs\errors.log -wait
Get-Content -Path c:\Logs\errors.log -Tail 10

## ldapsearch
Get-ADObject -LDAPFilter "DC=example,DC=com,cn=abertram"

## chown
$acl = Get-Acl c:\temp
$permission = "domainName\Username", "FullControl", "Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
$acl | Set-Acl c:\temp

## yum
Find-Package

## grep
Select-String -Path C:\logs\Errors.log -Pattern "something"
Get-WinEvent -FilterHashTable @{ 'LogName' = 'Application'; Level = 3 }

## find
(Get-ChildItem -Path C:\Dir).Where({ $_.Name -eq 'somefile.txt' })
Get-ChildItem -Path C:\Folder* -Recurse -Include somefile.txt

## du
(Get-ChildItem -Path 'C:\Windows' -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB

## df
(gwmi -Class win32_logicaldisk -Filter "DeviceID = 'C:'").freespace /1GB

## systemctl restart
Restart-Service -name apache

## lvextexnd
Resize-Partition -DriveLetter D -Size 10GB

## iostat
Get-Counter -Continuous

## free
Get-Counter '\Memory\Available MBytes'
gwmi win32_operatingsystem | select freephysicalmemory, totalvisiblememorysize, totalvirtualmemorysize, totalswapspacesize

## kill
kill
Stop-Process -Id 555

## ps -aux
ps
Get-Process

## top
Get-counter -Counter "\Processor(_Total)\% Processor Time" –Continuous

#endregion