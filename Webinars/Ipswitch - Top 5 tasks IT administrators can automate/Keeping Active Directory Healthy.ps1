<# 
 Title: Keeping Active Directory Healthy
 Prerequisites:
    Computer is in an Active Directory domain
    Domain administrator privileges
    PowerShell v4+
    Server 2012 R2 domain controllers
    Remote Server Administration Tools (RSAT) installed
      - with the Active Directory PowerShell module enabled
#>

#region Demo Setup

$Credential = Get-Credential ## p@$$w0rd16
$PSDefaultParameterValues.Add('*-Ad*:Server', 'DC')
Enter-PSSession -ComputerName dc -Credential $Credential
cd\
cls

#endregion

#region Intro to the Active Directory PowerShell module

Get-Module -Name ActiveDirectory -ListAvailable
Get-Command -Module ActiveDirectory

#endregion

#region Find all "stale" AD computer and user accounts

$OldestLoginInDays = 60

Search-ADAccount -AccountInactive -UsersOnly -TimeSpan $OldestLoginInDays | select name, lastlogondate
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan $OldestLoginInDays | select name, lastlogondate

#endregion

#region Find all unlinked GPOs

$gpos = Get-GPOReport -All -ReportType XML
([xml]$gpos).GPOs.GPO.Where({ -not $_.LinksTo })

#endregion

#region Find all empty groups

(Get-ADGroup -Filter * -Properties Members).where({ $_.Members.Count -eq 0 })

#endregion

#region Finding inactive GPOs

(Get-GPO -All).Where({ $_.GpoStatus -in 'AllSettingsDisabled', 'UserSettingsDisabled', 'ComputerSettingsDisabled' })

#endregion

#region Keeping directories in sync

## Pull out AD attributes into a CSV and MoveIT will take from there.
Get-ADUser -Filter { Enabled -eq $true } | select givenName, SurName, distinguishedName | Export-Csv -Path 'C:\ActiveDirectory.csv'
Import-Csv -Path C:\ActiveDirectory.csv

#endregion
