## Define all default properties that will apply across more than a single function
$GarageList = "$PSScriptRoot\MyGarages.csv"

function Get-Garage
{
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Address
	)
	process
	{
		if ($PSBoundParameters.ContainsKey('Address'))
		{
			Import-Csv -Path $GarageList | where { $PSItem.Address -eq $Address }
		}
		else
		{
			Import-Csv -Path $GarageList
		}
	}
}

function Set-Garage
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory,ValueFromPipeline,ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter(Mandatory,ParameterSetName = 'Address')]
		[ValidateNotNullOrEmpty()]
		[string]$Address,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Capacity,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$FloorType,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$AirConditioned,
	
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
	)
	process
	{
		if (-not $PSBoundParameters.ContainsKey('InputObject')) {
			$garage = Get-Garage -Address $Address
		}
		else
		{
			$garage = $InputObject
		}
		
		($csv = Import-Csv -Path $GarageList) | foreach {
			$row = $PSItem
			if ($_.Address -eq $garage.Address)
			{
				$PSBoundParameters.GetEnumerator() | where {$_.Key -notin 'InputObject','Address', 'PassThru'} | foreach {
					$row.($_.Key) = $_.Value
				}
			}
		}
		$csv | Export-Csv -Path $GarageList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			$csv | where {$_.Address -eq $garage.Address}	
		}
	}
}

function New-Garage
{
	[OutputType('System.Management.Automation.PSCustomObject')]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Address,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[int]$Capacity,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$FloorType,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$AirConditioned
	)
	process
	{
		$ht = @{}
		$PSBoundParameters.GetEnumerator() | foreach {
			$ht[$_.Key] = $_.Value
		}
		[pscustomobject]$ht | Export-Csv -Path $GarageList -Append -NoTypeInformation
		[pscustomobject]$ht
	}
}

function Remove-Garage
{
	[OutputType('System.Management.Automation.PSCustomObject')] ## If I use -PassThru
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory,ValueFromPipeline,ParameterSetName = 'InputObject')]
		[ValidateNotNullOrEmpty()]
		[pscustomobject]$InputObject,
		
		[Parameter(Mandatory,ParameterSetName = 'NoInputObject')]
		[ValidateNotNullOrEmpty()]
		[string]$Address,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$PassThru
		
	)
	process
	{
		if ($PSBoundParameters.ContainsKey('InputObject')) {
			$Address = $InputObject.Address
		}
		$garages = Import-Csv -Path $GarageList | where { $PSItem.Address -ne $Address }
		$garages | Export-Csv -Path $GarageList -NoTypeInformation
		if ($PassThru.IsPresent)
		{
			[pscustomobject]$garages	
		}
	}
}