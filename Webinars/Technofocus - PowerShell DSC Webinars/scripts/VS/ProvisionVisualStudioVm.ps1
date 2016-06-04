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

#Command line arguments
param(
$subscriptionName,
$storageAccount,
$serviceName,
$vmName,
$vmSize,
$imageName,
$availabilitySetName,
$dataDisks,
$adminUsername,
$adminPassword,
$subnetNames,
$domainDnsName,
$installerDomainUsername,
$installerDomainPassword,
$affinityGroup,
$choice,
$location
)
Import-Module Azure

# Create credential object
$secPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential($adminUsername, $secPassword)

$domainSecPassword = ConvertTo-SecureString $installerDomainPassword -AsPlainText -Force
$installerDomainCredential = New-Object System.Management.Automation.PSCredential($installerDomainUsername, $domainSecPassword)

# Ensure correct subscription and storage account is selected
Select-AzureSubscription -SubscriptionName $subscriptionName
Set-AzureSubscription $subscriptionName -CurrentStorageAccount $storageAccount

# Display current subscription
$currentSubscription = Get-AzureSubscription -Current
"Current subscription: {0}" -f $currentSubscription.SubscriptionName

# Include script file for shared functions
$scriptFolder = Split-Path -parent $MyInvocation.MyCommand.Definition
. "$scriptFolder\..\SharedComponents\SharedFunctions.ps1"

#Calls function in sharedfunctions.ps1 to creates a domain joined or stand-alone VM
if ($choice -ne 1)
  {
    CreateDomainJoinedAzureVmIfNotExists $serviceName $vmName $vmSize $imageName $availabilitySetName $dataDisks $vnetName $subnetNames $affinityGroup $adminUsername $adminPassword `
	  $domainDnsName $installerDomainUsername $installerDomainPassword
  }
else
  {
    CreateAzureVmIfNotExists $serviceName $vmName $vmSize $imageName $availabilitySetName $dataDisks $vnetName $subnetNames $affinityGroup $adminUsername $adminPassword $location
#	  $domainDnsName $installerDomainUsername $installerDomainPassword
  }
	
# Formatting data disks
FormatDisk $serviceName $vmName $installerDomainUsername $installerDomainPassword

Write-Host "Enabling CredSSP on $vmName"
EnableCredSSPServerIfNotEnabled $serviceName $vmName $installerDomainCredential