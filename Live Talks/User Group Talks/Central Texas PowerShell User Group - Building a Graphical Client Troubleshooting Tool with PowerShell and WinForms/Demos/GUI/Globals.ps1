#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------


#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

## UNC share where ancillary files are located
$toolFileShare = '\\MEMBERSRV1\ToolShare'

function Write-Status
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Message
	)
	$statusBar1.Text = $Message
}

function Test-VncInstalled
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
		[string]$ComputerName
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
		function Get-InstalledSoftware
		{
			<#
			.SYNOPSIS
				Retrieves a list of all software installed
			.EXAMPLE
				Get-InstalledSoftware
				
				This example retrieves all software installed on the local computer
			.PARAMETER Name
				The software title you'd like to limit the query to.
			.PARAMETER Guid
				The software GUID you'e like to limit the query to
			#>
			[CmdletBinding()]
			param (
				
				[Parameter()]
				[ValidateNotNullOrEmpty()]
				[ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
				[string[]]$ComputerName,
				
				[Parameter()]
				[ValidateNotNullOrEmpty()]
				[System.Management.Automation.PSCredential]$Credential,
				
				[string]$Name,
				
				[ValidatePattern('\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}\b')]
				[string]$Guid
			)
			process
			{
				try
				{
					$scriptBlock = {
						$UninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
						New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
						$UninstallKeys += Get-ChildItem HKU: | where { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | foreach { "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall" }
						if (-not $UninstallKeys)
						{
							Write-Warning -Message 'No software registry keys found'
						}
						else
						{
							foreach ($UninstallKey in $UninstallKeys)
							{
								$friendlyNames = @{
									'DisplayName' = 'Name'
									'DisplayVersion' = 'Version'
								}
								Write-Verbose -Message "Checking uninstall key [$($UninstallKey)]"
								if ($PSBoundParameters.ContainsKey('Name'))
								{
									$WhereBlock = { $_.GetValue('DisplayName') -like "$Name*" }
								}
								elseif ($PSBoundParameters.ContainsKey('GUID'))
								{
									$WhereBlock = { $_.PsChildName -eq $Guid }
								}
								else
								{
									$WhereBlock = { $_.GetValue('DisplayName') }
								}
								$SwKeys = Get-ChildItem -Path $UninstallKey -ErrorAction SilentlyContinue | Where-Object $WhereBlock
								if (-not $SwKeys)
								{
									Write-Verbose -Message "No software keys in uninstall key $UninstallKey"
								}
								else
								{
									foreach ($SwKey in $SwKeys)
									{
										$output = @{ }
										foreach ($ValName in $SwKey.GetValueNames())
										{
											if ($ValName -ne 'Version')
											{
												$output.InstallLocation = ''
												if ($ValName -eq 'InstallLocation' -and ($SwKey.GetValue($ValName)) -and (@('C:', 'C:\Windows', 'C:\Windows\System32', 'C:\Windows\SysWOW64') -notcontains $SwKey.GetValue($ValName).TrimEnd('\')))
												{
													$output.InstallLocation = $SwKey.GetValue($ValName).TrimEnd('\')
												}
												[string]$ValData = $SwKey.GetValue($ValName)
												if ($friendlyNames[$ValName])
												{
													$output[$friendlyNames[$ValName]] = $ValData.Trim() ## Some registry values have trailing spaces.
												}
												else
												{
													$output[$ValName] = $ValData.Trim() ## Some registry values trailing spaces
												}
											}
										}
										$output.GUID = ''
										if ($SwKey.PSChildName -match '\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}\b')
										{
											$output.GUID = $SwKey.PSChildName
										}
										[pscustomobject]$output
									}
								}
							}
						}
					}
					if ($PSBoundParameters.ContainsKey('ComputerName'))
					{
						$icmParams = @{
							'ComputerName' = $ComputerName
							'ScriptBlock' = $scriptBlock
						}
						if ($PSBoundParameters.ContainsKey('Credential'))
						{
							$icmParams.Credential = $Credential
						}
						Invoke-Command @icmParams
					}
					else
					{
						& $scriptBlock
					}
				}
				catch
				{
					Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
				}
			}
		}
	}
	process
	{
		try
		{
			if (Get-InstalledSoftware -ComputerName $ComputerName | where { $_.Name -eq 'UltraVNC' })
			{
				$true
			}
			else
			{
				$false
			}
		}
		catch
		{
			Write-Error $_.Exception.Message
		}
	}
}

function Deploy-Vnc
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
		[string]$ComputerName,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Path -Path $_ -PathType Container })]
		[string]$InstallerFolder = '\\MEMBERSRV1\ToolShare'
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
	}
	process
	{
		try
		{
			## Ensure the C$ share is available
			if (-not (Test-Path -Path "\\$ComputerName\c$"))
			{
				throw "The c`$ share is not available on computer [$($ComputerName)]"
			}
			else
			{
				Write-Verbose -Message "c$ share is available on [$($ComputerName)]"
			}
			
			$installFolderName = $InstallerFolder.Split('\')[-1]
			
			## Check if our installer and INF is already on the remote computer
			if (Test-Path -Path "\\$ComputerName\c$\$installFolderName")
			{
				Write-Verbose -Message "VNC install folder already exists at \\$ComputerName\c$\$installFolderName"
				
				## Generate file hashes for all files within the remote VNC install folder and the files on the remote client.
				$sourceHashes = Get-ChildItem -Path $InstallerFolder | foreach { (Get-FileHash -Path $_.FullName).Hash }
				$destHashes = Get-ChildItem -Path "\\$ComputerName\c$\$installFolderName" | foreach { (Get-FileHash -Path $_.FullName).Hash }
				if (Compare-Object -ReferenceObject $sourceHashes -DifferenceObject $destHashes)
				{
					Write-Verbose -Message 'Remote computer VNC installer contents does not match source. Overwriting...'
					## Copy the VNC installer folder to the remote computer
					Copy-Item -Path $InstallerFolder -Destination "\\$ComputerName\c$" -Recurse
				}
				else
				{
					Write-Verbose -Message 'Remote computer VNC installer contents already exist. No need to copy again.'
				}
			}
			else
			{
				## Copy the VNC installer folder to the remote computer
				Write-Verbose -Message "Copying VNC installer contents to [$($ComputerName)]"
				Copy-Item -Path $InstallerFolder -Destination "\\$ComputerName\c$" -Recurse
			}
			
			## Remotely invoke the VNC installer on the computer
			$localInstallFolder = "C:\$installFolderName".TrimEnd('\')
			$localInstaller = "$localInstallFolder\UltraVNC_Setup.exe"
			$localInfFile = "$localInstallFolder\UltraVNCSilentInstall.inf"
			
			$scriptBlock = {
				Start-Process $using:localInstaller -Args "/verysilent /loadinf=`"$using:localInfFile`"" -Wait -NoNewWindow
			}
			Write-Verbose -Message 'Running VNC installer...'
			Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock
		}
		catch
		{
			Write-Error $_.Exception.Message
		}
		finally
		{
			$remoteInstallFolder = "\\$ComputerName\c$\$installFolderName"
			Write-Verbose -Message "Cleaning up VNC install bits at [$($remoteInstallFolder)]"
			Remove-Item $remoteInstallFolder -Recurse -ErrorAction Ignore
		}
	}
}