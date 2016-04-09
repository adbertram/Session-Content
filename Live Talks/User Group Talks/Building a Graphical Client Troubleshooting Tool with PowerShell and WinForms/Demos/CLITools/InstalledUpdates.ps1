## Find installed updates on a test remote client
Get-HotFix -ComputerName CLIENT1

## Narrow this down to only the fields I'd like to see as defined by the helpdesk
Get-HotFix -ComputerName CLIENT1 | select description, hotfixid