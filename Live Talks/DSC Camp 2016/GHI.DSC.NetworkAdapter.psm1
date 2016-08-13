<#
	===========================================================================
	Organization:	Genomic Health, Inc.
	Filename:		GHI.DSC.NetworkAdapter.psm1
	===========================================================================
#>

Set-StrictMode -Version Latest;

enum Ensure
{
	Absent
	Present
}

enum DnsServerAddress_AbsentReason
{
	ServerMissing
	ServersDontMatch
	TooManyServers
}

[DscResource()]
class GHI_DnsServerAddress
{
	[DscProperty(Key)]
	[ValidateNotNullOrEmpty()]
	[string]$InterfaceAlias
	
	[DscProperty(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')]
	[string[]]$Address
	
	[DscProperty(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[Ensure]$Ensure
	
	[DscProperty()]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('IPV4', 'IPV6')]
	[string]$AddressFamily = 'IPV4'
	
	[DscProperty(NotConfigurable)]
	[ValidateNotNullOrEmpty()]
	[DnsServerAddress_AbsentReason[]]$AbsentReason
	
	[void] Set()
	{
		try
		{
			$getObject = $this.Get()
			
			if ($this.Ensure -eq [Ensure]::Present)
			{
				@($getObject.AbsentReason).foreach({
						switch ($_)
						{
							'ServerMissing'
							{
								Write-Verbose -Message "Thre are DNS server addresses missing."
							}
							'ServersDontMatch'
							{
								Write-Verbose -Message "DNS server addresses don't match."
							}
							'TooManyServers' {
								Write-Verbose -Message "There are too many DNS server addresses defined."
							}
							default
							{
								throw 'Unrecognized absent reason'
							}
						}
					})
				Set-DnsClientServerAddress -InterfaceAlias $this.InterfaceAlias -ServerAddresses $this.Address
			}
			else
			{
				throw 'Absent logic not implemented.'
			}
		}
		catch
		{
			throw $_
		}
	}
	
	[bool] Test()
	{
		return $This.Get().Ensure -eq $this.Ensure
	}
	
	[GHI_DnsServerAddress] Get()
	{
		try
		{
			$GetObject = [GHI_DnsServerAddress]::new()
			$GetObject.Ensure = [Ensure]::Present
			
			$clientParams = @{
				'AddressFamily' = $this.AddressFamily
				'InterfaceAlias' = $this.InterfaceAlias
				'ErrorAction' = 'Ignore'
			}
			
			$absentReasons = $null
			
			if (-not ($dnsClientServerAddresses = Get-DnsClientServerAddress @clientParams))
			{
				$aliases = (Get-DnsClientServerAddress).InterfaceAlias
				throw "Could not find network adapter with interface alias [$($this.InterfaceAlias)]. Possible aliases are [$($aliases -join ',')]"
			}
			
			if (@($dnsClientServerAddresses.ServerAddresses).Count -lt @($this.Address).Count)
			{
				$absentReasons = [DnsServerAddress_AbsentReason]::ServerMissing
			}
			elseif (@($dnsClientServerAddresses.ServerAddresses).Count -gt @($this.Address).Count)
			{
				$absentReasons = [DnsServerAddress_AbsentReason]::TooManyServers
			}
			else
			{
				$compParams = @{
					'ReferenceObject' = $dnsClientServerAddresses.ServerAddresses
					'DifferenceObject' = $this.Address
					'SyncWindow' = 0
				}
				if ($compare = Compare-Object @compParams)
				{
					$absentReasons = [DnsServerAddress_AbsentReason]::ServersDontMatch
				}
				
			}
			
			if ($absentReasons -ne $null)
			{
				$GetObject.Ensure = [Ensure]::Absent
				$GetObject.AbsentReason = $absentReasons
			}
			else
			{
				Write-Verbose -Message 'Computer is in the desired state.'
			}
			
			return $GetObject
		}
		catch
		{
			throw $_
		}
	}
}
