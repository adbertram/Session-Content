param (
	[Parameter(Mandatory)]
	[string[]]$ComputerName,

	[Parameter(Mandatory)]
	[string]$KbId,

	[Parameter(Mandatory)]
	[pscredential]$Credential
)

$deploymentScriptBlock = {

	$VerbosePreference = $using:VerbosePreference

	## Download the PSWindowsUpdate module from the PowerShell Gallery
	$provParams = @{
		Name           = 'NuGet'
		MinimumVersion = '2.8.5.208'
		Force          = $true
	}

	$null = Install-PackageProvider @provParams
	$null = Import-PackageProvider @provParams

	Install-Module -Name 'PSWindowsUpdate' -Force -Confirm:$false

	Install-WindowsUpdate -KBArticleID $using:KbId -Confirm:$false
}

$deploymentJobs = Invoke-Command -ComputerName $ComputerName -Scriptblock $deploymentScriptBlock -AsJob -Credential $Credential

while ($deploymentJobs | Where-Object { $_.State -eq 'Running'}) {
	Write-Verbose -Message "Waiting for all computers to finish..."
	Start-Sleep -Second 1
}

## Cleanup the jobs
$deploymentJobs | Remove-Job