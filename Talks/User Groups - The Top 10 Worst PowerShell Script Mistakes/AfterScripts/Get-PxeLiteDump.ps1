<#
	.SYNOPSIS
		This script queries a list of computer names for DMP files in the path C:\programdata\1e\pxelite of each computer. Once
		complete, the script will output all DMP files found sorted by the $SortBy parameter.

	.PARAMETER SccmModulePath
		The file path where the ConfigurationManager module is located. Since the ConfigurationManager module isn't located
		in a standard $PSModulePath it must be imported diretly via file path.

	.PARAMETER Site
		This is the 3-letter SCCM site that will be used as the PS drive to use the SCCM module.

	.EXAMPLE
		PS> .\Get-PxeLiteDemp.ps1

		This will look for all computers in the SCCM collection OSD Masters for all DMP files in the C:\programdata\1e\pxelite
		folder

	.INPUTS
		None. This script does not accept pipeline input.

	.OUTPUTS
		Sytem.IO.FileInfo

#>

[CmdletBinding()]
[OutputType([System.IO.FileInfo])]
param
(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$SccmModulePath
)
process {
	try
	{
		return
		if (-not $PSBoundParameters.ContainsKey('SccmModulePath')) {
			$SccmModulePath = "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
		}
		if (-not (Test-Path -Path $SccmModulePath -PathType Leaf))
		{
			throw "The SCCM module at [$($SccmModulePath)] does not exist"	
		}
		
		Write-Verbose -Message 'Importing SCCM module...'
		Import-Module -Name $SccmModulePath
		Write-Verbose -Message "Checking for PS drive [$($Site)]"
		if (-not (Get-PSDrive -Name $Site))
		{
			throw "The PS drive [$($Site)] was not found"
		}
		else
		{
			Write-Verbose -Message "The PS drive [$($Site)] was found"
		}
		$beforeLocation = (Get-Location).Path
		Set-Location -Path $Site
		Write-Verbose -Message "Checking [$($Devices.Count)] devices for .DMP files..."
		$dumps = [System.Collections.ArrayList]
		
		if (-not $PSBoundParameters.ContainsKey('Devices')) {
			$Devices = (Get-CMDevice -CollectionName "OSD Masters").Name
		}
		foreach ($device in $Devices) {
			try
			{
				$folderPath = "\\$device\c$\programdata\1e\pxelite"
				if ((Test-Connection -ComputerName $device -Quiet -Count 1) -and (Test-Path -Path $folderPath -PathType Container))
				{
					Write-Verbose -Message "[$($device)] is online and available. Getting all DMP files in [$($folderPath)]"
					$dumps.Add((Get-ChildItem "$folderPath\*.dmp" | select Fullname, LastWriteTime))
				}
				else
				{
					Write-Warning "[$($device)] is NOT available. Skipping..."
				}
			} catch {
				Write-Error -Message "Problem on device [$($device)]: $($_.Exception.Message)"	
			}
		}
		$dumps | Sort-Object -Descending $SortBy
	}
	catch
	{
		Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	}
	finally
	{
		Set-Location -Path $beforeLocation
	}
}