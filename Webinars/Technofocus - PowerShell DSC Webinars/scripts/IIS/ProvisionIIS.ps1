<#
 * Copyright Microsoft Corporation
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
#>

param([parameter(Mandatory=$true)][string]$configFilePath,
      [parameter(Mandatory=$true)][string]$choice,
      [parameter(Mandatory=$true)][string]$scriptFolder)

# Write-Host "Installing Windows 2012 R2 with IIS using Configuration Template: $configFilePath"

$config = [xml](gc $configFilePath)

$iisScriptPath = (Join-Path -Path $scriptFolder -ChildPath 'IIS\ProvisionIISVm.ps1') 

# Provision VMs in each VM Role
$vmRoles = $config.Azure.AzureVMGroups.VMRole

foreach($vmRole in $vmRoles )
{
	$subnetNames = @($vmRole.SubnetNames)
	$affinityGroup = $config.Azure.AffinityGroup
    $vnetName = $config.Azure.VNetName
    $azureVMs = $vmRole.AzureVM

	foreach($azureVm in $azureVMs)
	{		
		$dataDisks = @()
		foreach($dataDiskEntry in $vmRole.DataDiskSizesInGB.Split(';'))
		{
			$dataDisks += @($dataDiskEntry)
		}
		$availabilitySetName = $vmRole.AvailabilitySet
		if([string]::IsNullOrEmpty($availabilitySetName))
		{
			$availabilitySetName = $config.Azure.ServiceName
		}
		
		$password = GetPasswordByUsername $vmRole.AdminUsername $config.Azure.ServiceAccounts.ServiceAccount
        $domainInstallerPassword = GetPasswordByUsername $config.Azure.Connections.ActiveDirectory.ServiceAccountName $config.Azure.ServiceAccounts.ServiceAccount
		
		& $iisScriptPath -subscriptionName $config.Azure.SubscriptionName -storageAccount $config.Azure.StorageAccount `
		-vnetName $vnetName -subnetNames $subnetNames -vmName $azureVm.Name -serviceName $config.Azure.ServiceName -vmSize $vmRole.VMSize `
		-availabilitySetName $availabilitySetName -dataDisks $dataDisks -affinityGroup $affinityGroup `
        -ImageName $vmRole.StartingImageName -AdminUserName $vmRole.AdminUsername `
		-AdminPassword $password -DomainDnsName $config.Azure.Connections.ActiveDirectory.DnsDomain `
		-domainInstallerUsername $config.Azure.Connections.ActiveDirectory.ServiceAccountName `
		-domainInstallerPassword $domainInstallerPassword `
        -Choice $choice `
        -Location $config.Azure.Location `
        -endPoints $azureVm.endpoint `
        -scriptfolder $scriptFolder
        
	}
}
#End of Script