# script verification
$props = 'Initials','Department','Title','DistinguishedName','Enabled','Name','GivenName','SurName'
Get-ADUser -Filter { GivenName -eq 'Adam' -and SurName -eq 'Bertram'} -Properties $props | Select $props
Get-ADUser -Filter { GivenName -eq 'Joe' -and SurName -eq 'Murphy'} -Properties $props | Select $props
Get-ADGroupMember -Identity 'Gigantic Corporation Inter-Intra Synergy Group' | select name
Get-ADComputer -Filter {Name -eq 'ADAMCOMPUTER'} | select distinguishedName,Name
Get-ADComputer -Filter {Name -eq 'JOECOMPUTER'} | select distinguishedName,Name

get-vm -ComputerName hyperv -Name labdc.lab.local | Get-VMSnapshot | Restore-VMSnapshot -confirm:$false

# tool kickoff
$toolParams = @{
    'EmployeesCsv' = 'C:\Users.csv'
    'Verbose' = $true
}
## Run 3 times and monitor. Notice it accounts for different situations
& "C:\Dropbox\Powershell\GitRepos\Session-Content\Webinars\Pluralsight - Building Tools with PowerShell\Tool.ps1" @toolParams