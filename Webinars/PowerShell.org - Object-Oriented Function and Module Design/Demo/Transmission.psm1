## Define some variable here that we can get to at the Transmission and Tranmission level

## Define all default properties that will apply across more than a single function
$TransmissionList = "$PSScriptRoot\MyTransmissions.csv"

function Get-Transmission
{
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
		[Parameter(Mandatory,ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$Car
	)
	process
	{

		Import-Csv -Path $TransmissionList | where { $PSItem.CarVIn -eq $Car.VIN }
	}
}

function Set-Transmission
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Type,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Speed,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
	)
	process
	{
		if (-not $PSBoundParameters.ContainsKey('InputObject'))
		{
			$Transmission = Get-Transmission -SerialNumber $SerialNumber
		}
		else
		{
			$Transmission = $InputObject
		}
		
		($csv = Import-Csv -Path $TransmissionList) | foreach {
			$row = $PSItem
			if ($_.SerialNumber -eq $Transmission.SerialNumber)
			{
				$PSBoundParameters.GetEnumerator() | where { $_.Key -notin 'InputObject', 'SerialNumber', 'PassThru' } | foreach {
					$row.($_.Key) = $_.Value
				}
			}
		}
		$csv | Export-Csv -Path $TransmissionList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			$csv | where { $_.SerialNumber -eq $Transmission.SerialNumber }
		}
	}
}

function New-Transmission
{
	[OutputType('System.Management.Automation.PSCustomObject')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$Car,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SerialNumber,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Type,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[int]$Speed
	)
	process
	{
		$ht = @{ 'CarVIN' = $Car.VIN }
		$PSBoundParameters.GetEnumerator() | where { $_.Key -notin 'Car' } | foreach {
			$ht[$_.Key] = $_.Value
		}
		
		[pscustomobject]$ht | Export-Csv -Path $TransmissionList -Append -NoTypeInformation
		[pscustomobject]$ht
	}
}

function Remove-Transmission
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter(Mandatory, ParameterSetName = 'SerialNumber')]
		[ValidateNotNullOrEmpty()]
		[int]$SerialNumber,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Type,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Speed,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
		
	)
	process
	{
		if ($PSBoundParameters.ContainsKey('InputObject'))
		{
			$SerialNumber = $InputObject.SerialNumber
		}
		$Transmissions = Import-Csv -Path $TransmissionList | where { $PSItem.SerialNumber -ne $SerialNumber }
		$Transmissions | Export-Csv -Path $TransmissionList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			[pscustomobject]$Transmissions
		}
	}
}