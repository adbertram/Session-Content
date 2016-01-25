param($Computername, $Location = 'OU=Corporate Computers')

try {
    if (Get-AdComputer $Computername) {
	    Write-Error "The computer name '$Computername' already exists"
	    return
    }
} catch {

}

$DomainDn = (Get-AdDomain).DistinguishedName
$DefaultOuPath = "$Location,$DomainDn"

New-ADComputer -Name $Computername -Path $DefaultOuPath