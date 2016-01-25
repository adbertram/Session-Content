param ([string]$Computername, [hashtable]$Attributes)

## Attempt to find the Computername
try {
    $Computer = Get-AdComputer -Identity $Computername
    if (!$Computer) {
	    ## If the Computername isn't found throw an error and exit
	    Write-Error "The Computername '$Computername' does not exist"
	    return
}
} catch {

}

## The $Attributes parameter will contain only the parameters for the Set-AdComputer cmdlet
$Computer | Set-AdComputer @Attributes
