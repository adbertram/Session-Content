param($FirstName,$MiddleInitial,$LastName,$Location = 'OU=Corporate Users',$Title)

## Not the best use of storing the password clear text
## Google on using stored secure strings on the file system as a way to get around this
$DefaultPassword = 'p@$$w0rd12'
$DomainDn = (Get-AdDomain).DistinguishedName
$DefaultGroup = 'Gigantic Corporation Inter-Intra Synergy Group'

$Username = "$($FirstName.SubString(0,1))$LastName"
## Check if an existing user already has the first intial/last name username taken
try {
    if (Get-ADUser $Username) {
        ## If so, check to see if the first initial/middle initial/last name is taken.
        $Username = "$($FirstName.SubString(0,1))$MiddleInitial$LastName"
        if (Get-AdUser $Username) {
            Write-Warning "No acceptable username schema could be created"
            return
        }
    }
} catch {

}
$NewUserParams = @{
    'UserPrincipalName' = $Username
    'Name' = $Username
    'GivenName' = $FirstName
    'Surname' = $LastName
    'Title' = $Title
    'SamAccountName' = $Username
    'AccountPassword' = (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)
    'Enabled' = $true
    'Initials' = $MiddleInitial
    'Path' = "$Location,$DomainDn"
    'ChangePasswordAtLogon' = $true
}

New-AdUser @NewUserParams
Add-ADGroupMember -Identity $DefaultGroup -Members $Username