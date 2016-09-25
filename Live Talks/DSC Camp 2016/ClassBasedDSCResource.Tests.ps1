using module '.\GHI.DSC.NetworkAdapter.psm1'

InModuleScope 'GHI.DSC.NetworkAdapter' {
	
	describe 'Get' {
		
		## Instantiate a new GHI_NetworkAdapter object
		$dnsSrvAddress = [GHI_DnsServerAddress]::new()
		
		## Assign all the mandatory properties to the object. This sets all of the properties we'll be testing.
		$dnsSrvAddress.InterfaceAlias = 'Bogus'
		$dnsSrvAddress.Address = '8.8.8.8', '4.4.4.4'
		$dnsSrvAddress.Ensure = 'Present'
		
		it 'throws an exception if the interface alias is not found' {
			
			## Ensure that Get-DnsClientServerAddress is called with appropriate parameters when the Get() method is called
			mock 'Get-DnsClientServerAddress' -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			{ $dnsSrvAddress.Get() } | should throw "Could not find network adapter with interface alias [$($dnsSrvAddress.InterfaceAlias)]"
		}
		
		it 'detects when the computer has too many DNS server addresses defined' {
			
			mock 'Get-DnsClientServerAddress' {
				[pscustomobject]@{
					ServerAddresses = '2.2.2.2', '6.6.6.6', '4.4.4.4'
				}
			} -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			$result = $dnsSrvAddress.Get()
			$result.AbsentReason | should be 'TooManyServers'
			
		}
		
		it 'detects when the computer has too few DNS server addressess defined' {
			
			mock 'Get-DnsClientServerAddress' {
				[pscustomobject]@{
					ServerAddresses = '8.8.8.8'
				}
			} -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			$result = $dnsSrvAddress.Get()
			$result.AbsentReason | should be 'ServerMissing'
			
		}
		
		it 'detects when the computer DNS server addresses are out of order' {
			
			mock 'Get-DnsClientServerAddress' {
				[pscustomobject]@{
					ServerAddresses = '4.4.4.4', '8.8.8.8'
				}
			} -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			$result = $dnsSrvAddress.Get()
			$result.AbsentReason | should be 'ServersDontMatch'
			
		}
		
		it 'detects when the computer is in the right state' {
			
			mock 'Get-DnsClientServerAddress' {
				[pscustomobject]@{
					ServerAddresses = $dnsSrvAddress.Address
				}
			} -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			$result = $dnsSrvAddress.Get()
			$result.AbsentReason | should be $null
			
		}
		
	}
	
	describe 'Set' {
		
		## Instantiate a new GHI_NetworkAdapter object
		$dnsSrvAddress = [GHI_DnsServerAddress]::new()
		
		## Assign all the mandatory properties to the object
		$dnsSrvAddress.InterfaceAlias = 'Bogus'
		$dnsSrvAddress.Address = '8.8.8.8', '4.4.4.4'
		$dnsSrvAddress.Ensure = 'Present'
		
		## A mock object with no MockWith parameter. This essentially neuters the function.
		mock 'Set-DnsClientServerAddress'
		
		mock 'Get-DnsClientServerAddress' {
			[pscustomobject]@{
				ServerAddresses = '2.2.2.2'
			}
		} -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
		
		it 'throws an exception when the Ensure property is set to Absent' {
			
			$dnsSrvAddress.Ensure = 'Absent'
			{ $dnsSrvAddress.Set() } | should throw 'Absent logic not implemented'
			
		}
		
		## Notice the "attempts" verb. Unit tests don't confirm it actually did the thing
		it 'attempts to set the appropriate DNS server addresses' {
			
			mock 'Set-DnsClientServerAddress'
			
			$dnsSrvAddress.Ensure = 'Present'
			$dnsSrvAddress.Set()
			
			$assMParams = @{
				'CommandName' = 'Set-DnsClientServerAddress'
				'Times' = 1
				'Exactly' = $true
				'Scope' = 'It'
				'ParameterFilter' = {
					($InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias) -and
					(-not (Compare-Object $ServerAddresses $dnsSrvAddress.Address))
				}
			}
			Assert-MockCalled @assMParams
			
		}
		
		it 'returns $null when successful' {
			
			$assMParams = @{
				'CommandName' = 'Set-DnsClientServerAddress'
				'Times' = 1
				'Exactly' = $true
				'ParameterFilter' = {
					($InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias) -and
					(-not (Compare-Object $ServerAddresses $dnsSrvAddress.Address))
				}
			}
			Assert-MockCalled @assMParams
			
			$dnsSrvAddress.Set() | should be $null
			
		}
	}
	
	## No test describe block because nothing in Test()
}

"Invoke-Pester -Path 'C:\Dropbox\GitRepos\Session-Content\Live Talks\DSC Camp 2016\ClassBasedDSCResource.Tests.ps1'" | Set-Clipboard