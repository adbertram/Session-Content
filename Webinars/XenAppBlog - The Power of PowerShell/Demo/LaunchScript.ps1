<#
.SYNOPSIS
	This is the launch script for the SoftwareInstallManager PowerShell module. This script is reponsible for performing
	the deployment. It tests multiple clients for connectivity and if passed, it will deploy software onto each client.

.PARAMETER Client
	One or more client hostnames to deploy software to.

.PARAMETER Type
	The kind of deployment that will be performed. This can be either Install, Upgrade, Uninstall or Detect. This is important
	to match up the appropriate PS1 script name in the package folder.

.PARAMETER SwPackagePath
	The folder path that contains the software installer files and the deployment script.

.PARAMETER ModuleFolderPath
	The folder path that contains the SoftwareInstallManager module and any ancillary files.

.PARAMETER ModuleFilePath
	The file path to the SoftwareInstallManager PSM1 file.

.PARAMETER ClientDeploymentFolder
	The folder path to the folder that will be created on each client where all necessary files copied to.

.LINK
	https://github.com/adbertram/SoftwareInstallManager
#>

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string[]]$Client,
	[Parameter(Mandatory)]
	[ValidateSet('Install','Upgrade','Uninstall','Detect')]
	[string]$Type,
	[Parameter(Mandatory)]
	[ValidateScript( { Test-Path -Path $_ -PathType Container })]
	[string]$SwPackagePath,
	[Parameter()]
	[string]$ModuleFolderPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\XenAppBlog - The Power of PowerShell\Demo\SoftwareInstallManager',
	[Parameter()]
	[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
	[string]$ModuleFilePath = "$ModuleFolderPath\SoftwareInstallManager.psm1",
	[Parameter()]
	[string]$ClientDeploymentFolder = 'C:\MyDeployment'
)

$ErrorActionPreferences = 'Stop'
try {
	#region Ensure the install folder, the SoftwareInstallManager module and deployment script are OK
	## Test to ensure our shared module exists where we think it does
	if (-not (Test-Path -Path $ModuleFilePath -PathType Leaf)) {
		throw "SoftwareInstallManager module: BAD"
	} else {
		Write-Verbose -Message "SoftwareInstallManager module: GOOD"
	}
	## Test to ensure the deployment script is where we think it is
	if (-not (Test-Path -Path $SwPackagePath -PathType Container)) {
		throw "Deployment folder: BAD"
	} else {
		Write-Verbose -Message "Deployment folder: GOOD"
	}
	if (-not (Test-Path -Path "$SwPackagePath\$Type.ps1" -PathType Leaf)) {
		throw "Deployment script: BAD"
	} else {
		Write-Verbose -Message "Deployment script: GOOD"
	}
	#endregion
	
    #region Inserting the Import-Module and Start-Log lines into the top of the deployment script

	$DeploymentScriptText = Get-Content -Path "$SwPackagePath\$Type.ps1"
	if ((($DeploymentScriptText | Select-Object -First 2) -join '|') -ne "Import-Module $ClientDeploymentFolder\SoftwareInstallManager.psm1|Start-Log") {
		## The deployment script doesn't have the required Import-Module as the first line and Start-Log as the second line
		## Insert Import-Module as the first line and Start-Log as the second line
		
		## If there's already some other Import-Module line, delete it
		if (($DeploymentScriptText | Select-Object -First 1) -like 'Import-Module *') {
			## Remove the top Import-Module line
			$DeploymentScriptText = ($DeploymentScriptText | Select-Object -Skip 1)
		}
		## If some other Start-Log line then delete it also
		if (($DeploymentScriptText | Select-Object -First 1) -like 'Start-Log*') {
			## Remove the top Start-Log line
			$DeploymentScriptText = ($DeploymentScriptText | Select-Object -Skip 1)
		}
		## If some other working dir line then delete it also
		if (($DeploymentScriptText | Select-Object -First 1) -like '$WorkingDir*') {
			## Remove the top Start-Log line
			$DeploymentScriptText = ($DeploymentScriptText | Select-Object -Skip 1)
		}

		## Insert the new Import-Module line and the Start-Log line at the top of the deployment script
		$DeploymentScriptText = "Import-Module $ClientDeploymentFolder\SoftwareInstallManager.psm1",'Start-Log','$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent',$DeploymentScriptText

		Set-Content -Path "$SwPackagePath\$Type.ps1" –value $DeploymentScriptText
	}

	#endregion

	#region Removing existing jobs
	Write-Verbose -Message 'Cleaning up any pre-existing jobs'
	Get-Job | Remove-Job -Force
	#endregion

	#region Testing and deployment

	## We will be creating a folder in the root of the C drive called MyDeployment. We'll then copy
	## all files including the deployment script and all installer files into that folder.
	## Once copied, we'll then use PS remoting to execute the script
	## We need to make sure all the services that require this are available; ping, c$ share 
	## available and PS remoting is working
	foreach ($pc in $Client) {
		try {
            #region Testing connectivity, c$ share and PS remoting
			if (-not (Test-Connection -ComputerName $pc -Quiet -Count 1)) {
				throw "$pc`: OFFLINE"
				continue
			} else {
				Write-Verbose -Message "$pc`: ONLINE"
				## Convert the mydeployment local path to a UNC so it can be tested and created
				$RemoteFilePathDrive = ($ClientDeploymentFolder | Split-Path -Qualifier).TrimEnd(':')
				$UncClientFolder = "\\$pc\$RemoteFilePathDrive`$$($ClientDeploymentFolder | Split-Path -NoQualifier)"
				if (-not (Test-Path -Path "\\$pc\c$")) {
					throw "$pc`: C`$ share is NOT available"
					continue
				} else {
					Write-Verbose -Message "$pc`: C`$ share is available"
					if (-not (Test-WsMan -ComputerName $pc)) {
						throw "$pc`: PS Remoting Problem"
						continue
					} else {
						Write-Verbose -Message "$pc`: PS Remoting OK"
            #endregion
            #region Copy files and initiate deployment
						if ($PsCmdlet.ShouldProcess($pc,'Invoke deployment on client')) {
							if (-not (Test-Path -Path $UncClientFolder -PathType Container)) {
								Write-Verbose -Message "The deployment folder $ClientDeploymentFolder does not exist on client $pc. Creating it."
								$null = mkdir $UncClientFolder
							}
							Write-Verbose -Message "$pc`: Copying deployment scripts to client"
							Copy-Item -Path $SwPackagePath\* -Destination $UncClientFolder -Force
							Write-Verbose -Message "$pc`: Copying module folder to client"
							Copy-Item -Path $ModuleFolderPath\* -Destination $UncClientFolder -Force -Recurse
							Write-Verbose -Message "$pc`: Launching deployment script"
							$null = Invoke-Command -ComputerName $pc -ScriptBlock { & "$using:ClientDeploymentFolder\$using:Type.ps1" } -AsJob -ThrottleLimit 5
							Write-Verbose -Message "$pc`: Deployment script launched"	
						}
					}
				}
			}
            #endregion
		} catch {
			Write-Warning "$pc - $($_.Exception.Message)"
		}
	}

	#endregion

	#region Deployment monitoring
	$Timeout = 240
	$RunningTime = 0
	if ($PsCmdlet.ShouldProcess('Running deployments','Check status')) {
		do {
			$JobsLeft = (Get-Job | Where-Object {$_.State -in @('Running','NotStarted')}).Count
			if ($JobsLeft -gt 1) {
				Write-Verbose -Message "Waiting for all the deployments to finish up. There are $JobsLeft left."
			} else {
				Write-Verbose -Message 'Waiting for all the deployments to finish up. There is 1 left.'
			}
			Start-Sleep -Seconds 5
			$RunningTime += 5
			if ($RunningTime -eq $Timeout) {
				Write-Warning -Message "Timeout of $Timeout seconds has been exceeded waiting for jobs"
				break
			}
		} while (Get-Job | Where-Object {$_.State -in @('Running','NotStarted')})
	}
	#endregion

	#region Deployment result and cleanup

	Get-Job | Receive-Job

	Write-Verbose 'Cleaning up deployment folders on clients'
	foreach ($pc in $Client) {
		Remove-Item -Path "\\$pc\c$\$($ClientDeploymentFolder | Split-Path -Leaf)" -Recurse -ErrorAction SilentlyContinue
	}

	#endregion

	Write-Host "Deployment to $($Client.Count) clients complete!" -ForegroundColor Green

} catch {
	Write-Warning $_.Exception.Message

}