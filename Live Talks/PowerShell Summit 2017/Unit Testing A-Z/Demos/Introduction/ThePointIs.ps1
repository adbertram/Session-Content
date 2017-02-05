function Remove-Software
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [switch]$Force
    )

    ## Enumerate all software to find the GUID
    $guid = Get-InstalledSoftware -Name $Name | Select-Object -ExpandProperty Guid

    if ($Force.IsPresent) {
        ## Rip out the software with no regard for humanity
        ## Run MSIZap for the GUID
        Start-Process 'C:\msizap.exe' -ArgumentList "TWG! $guid" -Wait -NoNewWindow -PassThru

        ## Sometimes leaves software reg keys behind. Remove any if exist
        Remove-Item -Path "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\$guid" -Confirm:$false -Recurse
    } else {
        ## Atttempt to uninstall the software cleanly
        Start-Process 'msiexec.exe' -ArgumentList "/x `"$swGuid`" REBOOT=ReallySuppress /qn"  -PassThru -Wait -NoNewWindow
    }   
}

function Get-InstalledSoftware
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name       
    )

    ## Query the registry for installed software
    
}