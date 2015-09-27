[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$Client,
    [Parameter()]
    [string]$ClientDeploymentFolder = 'C:\MyDeployment'
)

foreach ($pc in $Client) {
    try {
        if (-not (Test-Connection -ComputerName $pc -Quiet -Count 1)) {
            Write-Warning -Message "$pc`: OFFLINE"
            continue
        } else {
            Write-Verbose -Message "$pc`: ONLINE"
            ## Convert the mydeployment local path to a UNC so it can be tested and created
            $RemoteFilePathDrive = ($ClientDeploymentFolder | Split-Path -Qualifier).TrimEnd(':')
            $RemoteDeploymentFolderPath = "\\$pc\$RemoteFilePathDrive`$$($ClientDeploymentFolder | Split-Path -NoQualifier)"
            if (-not (Test-Path -Path "\\$pc\c$")) {
                Write-Warning -Message "$pc`: C`$ share is NOT available"
                continue
            } else {
                Remove-Item -Path $RemoteDeploymentFolderPath -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
                Remove-Item -Path "\\$pc\c$\Windows\Temp\*.*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Error "$pc - $($_.Exception.Message)"
    }
}