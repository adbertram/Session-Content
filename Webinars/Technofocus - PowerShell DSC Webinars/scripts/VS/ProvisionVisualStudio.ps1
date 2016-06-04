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

param([parameter(Mandatory=$true)][string]$configFilePath)

Import-Module Azure

$scriptFolder = Split-Path -Parent (Split-Path -parent $MyInvocation.MyCommand.Definition)
$config = [xml](gc $configFilePath)

Select-AzureSubscription -SubscriptionName $config.Azure.SubscriptionName

$vsScriptPath = (Join-Path -Path $scriptFolder -ChildPath 'VS\ProvisionVisualStudioVm.ps1')

. "$scriptFolder\SharedComponents\SharedFunctions.ps1"


Use-RunAs

Write-Host "Installing Visual Studio 2013 using Configuration Template: $configFilePath"

$ouName = 'ServiceAccounts'
foreach($serviceAccount in $config.Azure.ServiceAccounts.ServiceAccount)
{
	if($serviceAccount.Username.Contains('\') -and ([string]::IsNullOrEmpty($serviceAccount.Create) -or (-not $serviceAccount.Create.Equals('No'))))
	{
		$username = $serviceAccount.Username.Split('\')[1]
		$password = $serviceAccount.Password
		$adminPassword = GetPasswordByUsername $config.Azure.Connections.ActiveDirectory.ServiceAccountName $config.Azure.ServiceAccounts.ServiceAccount
	}
}

# Provision VMs in each VM Role

foreach($vmRole in $config.Azure.AzureVMGroups.VMRole)
{
	$subnetNames = @($vmRole.SubnetNames)
	
	$affinityGroup = $config.Azure.AffinityGroup
    $vnetName = $config.Azure.VNetName
	foreach($azureVm in $vmRole.AzureVM)
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
        $installerDomainPassword = GetPasswordByUsername $config.Azure.Connections.ActiveDirectory.ServiceAccountName $config.Azure.ServiceAccounts.ServiceAccount
		
		& $vsScriptPath -subscriptionName $config.Azure.SubscriptionName -storageAccount $config.Azure.StorageAccount `
		-vnetName $vnetName -subnetNames $subnetNames -vmName $azureVm.Name -serviceName $config.Azure.ServiceName -vmSize $vmRole.VMSize `
		-availabilitySetName $availabilitySetName -dataDisks $dataDisks -affinityGroup $affinityGroup `
        -ImageName $vmRole.StartingImageName -AdminUserName $vmRole.AdminUsername `
		-AdminPassword $password -DomainDnsName $config.Azure.Connections.ActiveDirectory.DnsDomain `
		-InstallerDomainUsername $config.Azure.Connections.ActiveDirectory.ServiceAccountName `
		-InstallerDomainPassword $installerDomainPassword `
        -Choice $choice `
        -Location $config.Azure.Location
        
	}
}