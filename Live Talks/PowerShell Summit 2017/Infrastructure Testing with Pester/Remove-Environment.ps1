function Remove-Environment {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$ServiceInstance
    )

    ## Do some other stuff here

    #region Clean up the VMs associated with this environment

    ## Find the applicable VMs
    $siLeadingZero = ([string]$ServiceInstance).PadLeft(2,'0')

    ## Define the regex to find the VMs based on name

    ## This is the correct regex
    #$nameRegex = "^$EnvironmentId\w{3}$siLeadingZero\w{3}\d{2}"

    ## This is not. Not much of a difference, huh?
    $nameRegex = "^$EnvironmentId\w{3}$siLeadingZero\w{3}\d{2}"

    ## Attempt to find the matching VMs in VMM

    ## Actual names typically returned by Get-SCVirtualMachine
    $vmList = @(
        'BAPP01GEN01'
        'BAPP02GEN02'
        'BSQL02GEN01'
        'BAPP06RRR01'
        'BSQL07LAB01'
        'BAPP08RRS04'
        'BAPP06BTA03'
        ## a whole lot more VMs here
    )
    $vmsToRemove = @($vmList).where({ $_ -match $nameRegex })
    #$vmsToRemove = @(Get-SCVirtualMachine).where({ $_.Name -match $nameRegex })

    ## Rmove the VMs
    if ($PSCmdlet.ShouldProcess("Remove VMs:$($vmsToRemove.Nme -join "`n")", '----------------------','Are you sure?'))
    {
        ## Remove all found VMs here
    }
    #endregion

    ## Do some other stuff here
}

Remove-Environment -EnvironmentId B -ServiceInstance 2 -Confirm:$false