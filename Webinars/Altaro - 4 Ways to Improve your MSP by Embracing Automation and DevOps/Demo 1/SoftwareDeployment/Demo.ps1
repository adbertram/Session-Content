## Deploy a new zero-day KB patch to multiple computers

$credential = Get-Credential

& "$PSScriptRoot\Deploy-WindowsPatch.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -Credential $credential

& "$PSScriptRoot\Deploy-VNC.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -Credential $credential