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
