#Starts defragmentation on C: with HIGH priority and verbose output
start-process defrag.exe -argumentlist "c: -f -v"
#Updates group policy for user and computer
start-process gpupdate -argumentlist /force
#Updates McAfee VirusScan Definitions
start-process mcupdate.exe -workingdirectory "c:\Program Files (x86)\McAfee\VirusScan Enterprise" -argumentlist /update
#Runs PatchMeNow
start-process pmn.exe -workingdirectory c:\scripts\patch
#Delete all temp files
remove-item $env:temp\* -force -recurse
remove-item c:\windows\temp\* -force -recurse
remove-item c:\temp\* -force -recurse
#Map P:\ and I:\ drives
net use P: /delete
net use I: /delete
net use P: \\server01\pdrive /persistent:yes
net use I: \\server02\idrive /persistent:yes
#Restart the VM after 15 minutes
start-process shutdown.exe -argumentlist "-r -t 900"