## Define some variable here that we can get to at the Car and Tranmission level

## Define all default properties that will apply across more than a single function
$CarList = "$PSScriptRoot\MyCars.csv"

function Get-Car
{
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$VIN
	)
	process
	{
		if ($PSBoundParameters.ContainsKey('VIN'))
		{
			Import-Csv -Path $CarList | where { $PSItem.VIN -eq $VIN }
		}
		else
		{
			Import-Csv -Path $CarList
		}
	}
}

function Set-Car
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter(Mandatory, ParameterSetName = 'VIN')]
		[ValidateNotNullOrEmpty()]
		[int]$VIN,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Make,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Model,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Year,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
	)
	process
	{
		if (-not $PSBoundParameters.ContainsKey('InputObject'))
		{
			$Car = Get-Car -VIN $VIN
		}
		else
		{
			$Car = $InputObject
		}
		
		($csv = Import-Csv -Path $CarList) | foreach {
			$row = $PSItem
			if ($_.VIN -eq $Car.VIN)
			{
				$PSBoundParameters.GetEnumerator() | where { $_.Key -notin 'InputObject', 'VIN', 'PassThru' } | foreach {
					$row.($_.Key) = $_.Value
				}
			}
		}
		$csv | Export-Csv -Path $CarList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			$csv | where { $_.VIN -eq $Car.VIN }
		}
	}
}

function New-Car
{
	[OutputType('System.Management.Automation.PSCustomObject')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$Garage,
	
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[int]$VIN,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Make,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Model,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[int]$Year
	)
	process
	{
		$ht = @{'GarageAddress' = $Garage.Address }
		$PSBoundParameters.GetEnumerator() | where { $_.Key -notin 'Garage' } | foreach {
			$ht[$_.Key] = $_.Value	
		}

		[pscustomobject]$ht | Export-Csv -Path $CarList -Append -NoTypeInformation
		[pscustomobject]$ht
	}
}

function Remove-Car
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter(Mandatory, ParameterSetName = 'VIN')]
		[ValidateNotNullOrEmpty()]
		[string]$GarageAddress,
		
		[Parameter(Mandatory, ParameterSetName = 'VIN')]
		[ValidateNotNullOrEmpty()]
		[int]$VIN,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Make,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Model,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Year,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
		
	)
	process
	{
		if ($PSBoundParameters.ContainsKey('InputObject'))
		{
			$VIN = $InputObject.VIN
		}
		$Cars = Import-Csv -Path $CarList | where { $PSItem.VIN -ne $VIN }
		$Cars | Export-Csv -Path $CarList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			[pscustomobject]$Cars
		}
	}
}