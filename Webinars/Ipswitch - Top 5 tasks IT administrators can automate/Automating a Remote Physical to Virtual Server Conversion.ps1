#Requires -Version 4

function Convert-PhysicalDiskVolume
{
	<#
	.SYNOPSIS
		This function converts all disks on a remote physical compputer to VHDs and transfers them to a location.
		
	.DESCRIPTION
		Remote computer requirements:
			PowerShell remoting enabled and available
			The C$ share is available
		
	.EXAMPLE
		PS> Convert-PhysicalDiskVolume -ComputerName SRV1 -DestinationFolderPath '\\MEMBERSRV1\VHDs'
	
		This example would convert all disk volumes to VHDs on the remote computer SRV1 and transfer all of the VHDs
		to the \\MEMBERSRV1\VHDs folder.
	
	.PARAMETER ComputerName
		The name of the computer you'd like to run this function against.
	
	.PARAMETER DestinationFolderPath
		Where you'd like to copy the VHDs to after completion.
	
	.PARAMETER Disk2VhdFilePath
		The shared location where the disk2vhd.exe file is located.
	
	.PARAMETER PsExecFilePath
		The shared location where the psexec.exe file is located. This is used to kick off disk2vhd.exe.
	
	.PARAMETER TempVhdFolderPath
		When Disk2vhd.exe runs, it will create a VHD on the remote computer. This is the path where it will send the VHD
		before getting transferred to Disk2VhdFilePath.
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
		[string[]]$ComputerName,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$DestinationFolderPath,
	
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
		[string]$Disk2VhdFilePath = '\\MEMBERSRV1\c$\Utilities\Disk2Vhd.exe',
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$PsExecFilePath = 'C:\psexec.exe',
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$TempVhdFolderPath = 'C:\'
	)
	begin {
		$ErrorActionPreference = 'Stop'
	}
	process {
		try
		{
			## Loop through each computer. $ComputerName can be multiple computers do to a string collection "[]" as the parameter
			@($ComputerName).foreach({
				try
				{
					$computer = $_
					$remotingParams = @{
						'ComputerName' = $computer
					}
					
					#region Ensure all is well before proceeding
					$remoteVhdFileName = "$computer.vhd"
					$disk2VhdFileName = $Disk2VhdFilePath | Split-Path -Leaf
					
					Write-Verbose -Message 'Ensuring c$ share is available...'
					if (-not (Test-Path -Path "\\$computer\c$"))
					{
						throw "The c$ share on [$($computer)] is not available."
					}
					
					Write-Verbose -Message 'Enuring PowerShell remoting is available...'
					if ((Invoke-Command @remotingParams -ScriptBlock { 1 }) -ne 1)
					{
						throw "PowerShell remoting connect failed."
					}
					#endregion
					
					## Copy Disk2Vhd to remote computer
					if (-not (Test-Path -Path "\\$computer\c$\$disk2VhdFileName" -PathType Leaf))
					{
						Write-Verbose -Message "Copying [$($Disk2VhdFilePath)] to [\\$computer\c$]"
						Copy-Item -Path $Disk2VhdFilePath -Destination "\\$computer\c$"
					}
					
					## Convert all disks to VHD
					Write-Verbose -Message "Converting all volumes on [$($computer)] to VHDs"
					
					<# 
					& $PsExecFilePath "\\$computer" -accepteula -h "C:\$disk2VhdFileName" * "C:\$remoteVhdFileName" -accepteula
					We're cheating for the demo. I already have a VHD created in C:\ on the remote server. This would
					take way too long.
					#>
					
					## Copy and remove the VHD(s) to the end path
					$remoteVhdFilePathUnc = "\\$computer\c$\$remoteVhdFileName"
					if (-not (Test-Path -Path $remoteVhdFilePathUnc -PathType Leaf))
					{
						throw "The expected VHD [$($remoteVhdFilePathUnc)] was not found."
					}
					
					Write-Verbose -Message "Copying VHDs to final destination..."
					Copy-Item -Path $remoteVhdFilePathUnc -Destination $DestinationFolderPath
				}
				catch
				{
					Write-Error -Message $_.Exception.Message
				}
				finally
				{
					## Cleanup disk2vhd.exe on the remote computer
					if (Test-Path Variable:\remoteVhdFilePathUnc)
					{
						Remove-Item -Path $remoteVhdFilePathUnc -ErrorAction SilentlyContinue
					}
				}
			})
			
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
}