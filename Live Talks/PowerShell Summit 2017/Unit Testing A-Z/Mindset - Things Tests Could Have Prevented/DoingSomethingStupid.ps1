## Snippet before I got stupid. Nice code that does a cleanup of workstation temp folders. 
## Could be dangerous so we add a -Confirm:$true
$tempFolderLocation = 'Windows\Temp'

$computers = Get-AdComputer -Filter * | Select -ExpandProperty Name
foreach ($computer in $computers) {
    Get-ChildItem -Path "\\$computer\C`$\$tempFolderLocation" -Recurse | Remove-Item -Confirm:$true
}


## Cue the stupidity. It's Friday. I'm tired and could care less about this stupid code. I just want to go home now.
## I'm trying to get something to work here and the thing keeps prompting me. Annoying!

# $tempFolderLocation = 'Windows\Temp'

$computers = Get-AdComputer -Filter * | Select -ExpandProperty Name
foreach ($computer in $computers) {
    Get-ChildItem -Path "\\$computer\C`$\$tempFolderLocation" -Recurse | Remove-Item -Confirm:$false
}