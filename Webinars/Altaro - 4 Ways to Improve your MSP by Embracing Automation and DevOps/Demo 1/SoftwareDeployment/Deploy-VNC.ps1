#Requires -Version 4
function Deploy-Vnc {
	<#
	.SYNOPSIS
		This function deploys the UltraVNC software package to a remote computer.
		
	.EXAMPLE
		PS> Deploy-VNC -ComputerName CLIENT1 -InstallFolder \\MEMBERSRV1\VNC
	
		This example copies all files from \\MEMBERSRV1\VNC which should contain a file called setup.exe representing the UltraVNC
		installer and silentinstall.inf representing the UltraVNC silent install answer file. These files will be copied to
		CLIENT1 in a VNC folder and executed to install UltraVNC.
		
	.PARAMETER ComputerName
		The name of the computer(s) you'd like to run this function against. This is mandatory.
	
	.PARAMETER InstallerFolderPath
		The folder that contains the UltraVNC installer (setup.exe) and the UltraVNC answer file (silentinstall.inf). This is mandatory.

	.PARAMETER Credential
		A PSCredential object representing alternate username and password to connect to the remote computer.
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string[]]$ComputerName,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Path -Path $_ -PathType Container })]
		[string]$InstallerFolderPath,

		[Parameter(Mandatory)]
		[pscredential]$Credential
	)
	
	$installFolderName = $InstallerFolderPath.Split('\')[-1]
	
	foreach ($c in $ComputerName) {
		try {
			$jobBlock = {
				$uncInstallerFolder = "\\$c\c$\$installFolderName"
				Copy-Item -Path $InstallerFolderPath -Destination "\\$c\c$" -Recurse
					
				$scriptBlock = { 
					$VerbosePreference = $using:VerbosePreference
					
					## Remotely invoke the VNC installer on the computer
					$localInstallFolder = "C:\$using:installFolderName".TrimEnd('\')
					$localInstaller = "$localInstallFolder\Setup.exe"
					$localInfFile = "$localInstallFolder\silentnstall.inf"

					Start-Process $using:localInstaller -Args "/verysilent /loadinf=`"$using:localInfFile`"" -Wait -NoNewWindow
				}
				Invoke-Command -ComputerName $c -ScriptBlock $scriptBlock -Credential $Credential
			}
			$jobs = Start-Job -ScriptBlock $jobBlock
			
		} catch {
			$PSCmdlet.ThrowTerminatingError($_)
		} finally {
			$remoteInstallFolder = "\\$c\c$\$installFolderName"
			Write-Verbose -Message "Cleaning up VNC install bits at [$($remoteInstallFolder)]"
			Remove-Item $remoteInstallFolder -Recurse -ErrorAction Ignore
		}
	}
	while ($jobs | Where-Object { $_.State -eq 'Running'}) {
		Write-Verbose -Message "Waiting for all computers to finish..."
		Start-Sleep -Second 1
	}
}