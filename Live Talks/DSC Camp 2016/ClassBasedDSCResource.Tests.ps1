using module '.\GHI.DSC.NetworkAdapter.psm1'

InModuleScope 'GHI.DSC.NetworkAdapter' {
	
	describe 'Get' {
		
		## Instantiate a new GHI_NetworkAdapter object
		$dnsSrvAddress = [GHI_DnsServerAddress]::new()
		
		## Assign all the mandatory properties to the object
		$dnsSrvAddress.InterfaceAlias = 'Bogus'
		$dnsSrvAddress.Address = '8.8.8.8','4.4.4.4'
		$dnsSrvAddress.Ensure = 'Present'
		
		it 'throws an exception if the interface alias is not found' {
			
			mock 'Get-DnsClientServerAddress' -ParameterFilter { $InterfaceAlias -eq $dnsSrvAddress.InterfaceAlias }
			
			{ $dnsSrvAddress.Get() } | should throw "Could not find network adapter with interface alias [$($dnsSrvAddress.InterfaceAlias)]"
		}
		
		it 'detects when the computer has too many DNS server addresses defined' {
			
			mock 'Get-DnsClientServerAddress' {
				[pscustomobject]@{
					ServerAddresses = '2.2.2.2','6.6.6.6','4.4.4.4'
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
					ServerAddresses = '4.4.4.4','8.8.8.8'
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
		
		#region Mocks
		mock 'Write-Log'
		
		mock 'Get-CallerPreference'
		
		mock 'New-Error'
		#endregion	
		
		$params = @{
				
		}
		
		it 'does not throw an exception or non-terminating error when called with all default parameters' {		
			
			$funcError = $null
			$null = Set @params -ErrorAction SilentlyContinue -ErrorVariable funcErr
			$funcError | should be $null
			Assert-MockCalled 'Write-Log' -ParameterFilter {$EntryType -eq 'Error'} -Times 0
		}
		
		it 'returns returnCount object(s) of type returnObjectType' {
			
			$result = Set @params
			@($result).Count | should be returnCount
			$result | should beoftype returnObjectType
		}
	}
	}
}