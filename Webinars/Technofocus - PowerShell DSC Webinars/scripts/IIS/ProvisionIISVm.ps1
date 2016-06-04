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
$domainInstallerUsername,
$domainInstallerPassword,
$affinityGroup,
$choice,
$location,
$endPoints,
$scriptFolder
)

# Create credential object
#$secPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
#$credential = SetCredential New-Object System.Management.Automation.PSCredential($adminUsername, $secPassword)
$credential = (SetCredential -Username $adminUsername -Password $adminPassword)

#$domainSecPassword = ConvertTo-SecureString $installerDomainPassword -AsPlainText -Force
#$installerDomainCredential = New-Object System.Management.Automation.PSCredential($installerDomainUsername, $domainSecPassword)
#$installerDomainCredential = (SetCredential -Username $domainInstallerUsername -Password $domainInstallerPassword)


#Ensure correct subscription and storage account is selected
#Select-AzureSubscription -SubscriptionName $subscriptionName
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccount

#Calls function in sharedfunctions.psm1 to creates a domain joined or stand-alone VM
if ($choice -ne 1)
  {
    CreateDomainJoinedAzureVmIfNotExists `
     -serviceName $serviceName `
     -vmName $vmName `
     -Size $vmSize `
     -imageName $imageName `
     -availabilitySetName $availabilitySetName `
     -dataDisks ($dataDisks) `
     -vnetName $vnetName `
     -subnetNames $subnetNames `
     -affinityGroup $affinityGroup `
     -adminUsername $adminUsername `
     -adminPassword $adminPassword `
	 -domainDNSName $domainDnsName `
     -domainInstallerUsername $domainInstallerUsername `
     -domainInstallerPassword $domainInstallerPassword `
     -endPoints $endPoints
  }
else
  {
    CreateAzureVmIfNotExists `
     -serviceName $serviceName `
     -vmName $vmName `
     -size $vmSize `
     -imageName $imageName `
     -availabilitySetName $availabilitySetName `
     -dataDisks ($dataDisks) `
     -vnetName $vnetName `
     -subnetNames $subnetNames `
     -affinityGroup $affinityGroup `
     -adminUsername $adminUsername `
     -adminPassword $adminPassword `
     -location $location `
     -scriptFolder $scriptFolder `
     -endPoints $endPoints
  }

#Get the hosted service WinRM Uri
[System.Uri]$uris = (GetVMConnection -ServiceName $serviceName -vmName $vmName)
if ($uris -eq $null){return}

# Formatting data disks
FormatDisk `
   -uris $uris `
   -Credential $credential

 Invoke-command -ConnectionURI $URIS.ToString() -Credential $credential -OutVariable $Result -ErrorVariable $ErrResult -ErrorAction SilentlyContinue -ScriptBlock {

		Set-ExecutionPolicy Unrestricted -Force
        
        #Hide green status bar
        $ProgressPreference = "SilentlyContinue"
        
        #Install IIS and IIS Management tools
        
        Write-Host "   Importing Server Manager Module" -NoNewline
        Import-Module -Name ServerManager
        Write-Host -ForegroundColor Green "... Completed"

        Write-Host "   Installing IIS and IIS Management Tools" -NoNewline
        Install-WindowsFeature -Name Web-Server -IncludeManagementTools -OutVariable $Result | Out-Null
        Write-Host -ForegroundColor Green "... Completed"
}
#End of Script