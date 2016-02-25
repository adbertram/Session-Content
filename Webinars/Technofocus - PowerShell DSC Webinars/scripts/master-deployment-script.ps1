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

 # Set path to shared functions

  $scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition

  ##Load the functions
  Import-Module $scriptFolder\SharedComponents\SharedFunctions.psm1 -AsCustomObject -Force -DisableNameChecking -Verbose:$false
    
 <#
  * To create the 3 different environments, the script must be run with elevated credentials
 #>
    
 if((IsAdmin) -eq $false)
   {
     Write-Host "Must run PowerShell elevated."
     return
  }
 
  <#
  * Enable the ByPass PowerShell execution policy by running Set-ExecutionPolicy ByPass. 
  * This will allow the downloaded scripts to run without individually prompting you
 #>

 Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

 if(!(Get-AzureAccount))
   {
     Add-AzureAccount
   }

 <#
  * Menu to create environments, shutdown VMs, Start VMs, or delete environment
  #>

cls
Write-Host; Write-Host -ForegroundColor Yellow "  Please select an option" ; Write-Host
Write-Host "   1:   Create Standalone SQL IIS Dev/Test environment"
Write-Host "   2:   Create Domain based SQL IIS Dev/Test environment"
Write-Host "   3:   Create Sharepoint Dev/Test environment"
Write-Host "   4:   Shutdown the VMs"
Write-Host "   5:   Start the VMs"
Write-Host "  99:   Delete the entire environment. ALL DATA WILL BE LOST"
Write-Host " "
$choice = Read-Host "--->"

##GP 06/12/2014 - Added transcript file
$TransScript = "Deployment_$((Get-Date -Format "MMddyyyy"))_$((randomString -length 10)).txt"
Start-Transcript -path ($TransScript) | Out-Null

if (($choice -eq 1) -or ($choice -eq 2) -or ($choice -eq 3))
  {
    # Menu for selecting the Datacenter region for the deployment
    
    Write-Host
    Write-Host -ForegroundColor Yellow "  Please select a Region" ; Write-Host
    Write-Host "   1:   US East          (Virginia)"
    Write-Host "   2:   US West          (California)"
    Write-Host "   3:   US North Central (Illinois)"
    Write-Host "   4:   US South Central (Texas)"
    Write-Host "   5:   Europe North     (Ireland)"
    Write-Host "   6:   Europe West      (Netherlands)"
    Write-Host " "
    $regionChoice = Read-Host "--->"
    Write-Host
     
    Switch($regionChoice)
      {
        1 { # US East          (Virginia)
            $region = "East US"
          }
        2 { # US West          (California)
            $region = "West US"
          }
        3 { # US North Central (Illinois)
            $region = "North Central US"
          }
        4 { # US South Central (Texas)
            $region = "South Central US"
          }
        5 { # Europe North     (Ireland)
            $region = "North Europe"
          }
        6 { # Europe West      (Netherlands)
            $region = "West Europe"
          }
  Default { # Incorrect choice
            Write-Host; Write-Host -ForegroundColor Yellow -BackgroundColor Red "WARNING:  Region choice not recognized. Exiting" ; Write-Host
            Stop-Transcript | Out-Null
            return
          }
      }


    ## Parameters
    ## -Choice - Requred - Used for the creation specific environment to create
    ## -ServiceName - Optional - Cloud Service name for VMs. Will be created (name generated automatically if not specified)
    ## -ScriptFolder - path to configuration files 
    ## -SubscriptionName - Optional - name of your subscription as configured in PowerShell. Uses Get-AzureSubscription -Current if not specified.
    ## -StorageAccountName - Optional - name of the storage account to use. One is created if not specified. Must be in the same location as -Location.
    ## -adminAccount - Optional - user name that will be created for the deployment (AD and Local account will be created) - default spadmin
    ## -adminPassword - Optional - password for service accounts for AD/SQL/SharePoint - randomly created if not specified 
    ## -appPoolAccount - Optional - user name that will be created for the SharePoint App Pools - default spfarm
    ## -appPoolPassword - Optional - password for app pool identity - default is the admin password
    ## -domain - Optional - netbios domain name - default corp
    ## -dnsDomain - Optional - FQDN - default corp.contoso.com
    ## -configOnly $true/$false - optional - default $false - pass if you want to create the configuration files but not run the deployment scripts. Note: Will create a storage account if one is not specified.
    ## -doNotShowCreds - optional - if you do not want the credentials displayed at the end of the script.

     
    . "$scriptFolder\SharedComponents\autoconfigure.ps1" -Location $region -ScriptFolder $scriptFolder -Choice $choice
  }
         
elseif (($choice -eq 4) -or ($choice -eq 5) -or ($choice -eq 99))
  {
    Write-Host; Write-Host -ForegroundColor Yellow "Initializing" -NoNewline

    # Load the Auto Generated config file to retrieve Storage account and Service Name

    $autoSqlConfig = "$scriptFolder\Config\SQL-Sample-AutoGen.xml"
    [xml] $config = gc $autoSqlConfig

    # Get the Azure Service account name from the Config file
    $cloudServiceName = $config.Azure.ServiceName

    #Get the Azure Storage account from the Config file
    $StorageAccount = $config.Azure.StorageAccount

    $AzureSubName = (Get-AzureSubscription)[0].SubscriptionName
                 
    Write-Host -ForegroundColor Green "... Complete" ; Write-Host

    Write-Host "Using "
    Write-Host "Storage Account {$($StorageAccount)}"
    Write-Host "Cloud Service {$($CloudServiceName)}"
    Write-Host "Subscription {$($AzureSubName)}"
    Write-Host ; Write-Host
                                            
            
    Switch($choice) 
      {
        4 {# Shut down the VMs
       
            $vms = Get-AzureVM -ServiceName $CloudServiceName
          
            Foreach($vm in $vms)
              {
                Write-Host -ForegroundColor Yellow "Shutting down VM $($vm.name)" -NoNewline
                Stop-AzureVM -ServiceName $CloudServiceName -Name $vm.Name -Force | Out-Null
                Write-Host -ForegroundColor Green "... Completed" ; Write-Host
              }
          }

        5 {# Start the VMs
            
            $vms = Get-AzureVM -ServiceName $CloudServiceName
          
            Foreach($vm in $vms)
              {
                Write-Host -ForegroundColor Yellow "Starting VM $($vm.Name)" -NoNewline
                Start-AzureVM -ServiceName $CloudServiceName -Name $vm.Name | Out-Null
                Write-Host -ForegroundColor Green "... Completed" ; Write-Host
              }
          }

       99 {# Remove the solution. This deletes all VMs and data

            $vms = Get-AzureVM -ServiceName $CloudServiceName
               
            Foreach($vm in $vms)
              {
                Write-Host -ForegroundColor Yellow "Removing VM $($vm.name)" -NoNewline
                Remove-AzureVM -ServiceName $CloudServiceName -Name $vm.name -DeleteVHD | Out-Null
                Write-Host -ForegroundColor Green "... Completed" ; Write-Host
              }

            # Pause for Azure to complete transactions
    
            Wait -msg "Waiting for Azure" -inSeconds 30 ; Write-Host

            # Remove any leftover Iaas Disks
            $vmdisks = Get-AzureDisk
            Write-Host -ForegroundColor Yellow "Removing any leftover IaaS VHDs" -NoNewline
            foreach($vmdisk in $vmdisks)
              {
                if($vmdisk.Attachedto.HostedServiceName = $CloudServiceName)
                  {
                    Remove-AzureDisk -DiskName $vmdisk.DiskName | Out-Null
                  }
              }
            Write-Host -ForegroundColor Green "... Completed" ; Write-Host

            # Pause for Azure to complete transactions
    
            Wait -msg "Waiting for Azure" -inSeconds 30 ; Write-Host

            #  Remove any existing Azure Cloud Service
            $azureService = Get-AzureService -ServiceName $CloudServiceName -WarningAction SilentlyContinue

            if($azureService)
              {
                Write-Host -ForegroundColor Yellow "Cloud service: $CloudServiceName found!, deleting it" -NoNewline
                Remove-AzureService -ServiceName $CloudServiceName -Force -WarningAction SilentlyContinue | Out-Null
                Write-Host -ForegroundColor Green "... Completed" ; Write-Host
              }
 
            # Pause for Azure to complete transactions
    
            Wait -msg "Waiting for Azure" -inSeconds 30 ; Write-Host

            # Remove Storage Account
            Write-Host -ForegroundColor Yellow "Deleting storage account $storageAccount" -NoNewline
            Remove-AzureStorageAccount -StorageAccountName $StorageAccount -WarningAction SilentlyContinue | Out-Null
            Write-Host -ForegroundColor Green "... Completed" ; Write-Host

            # Pause for Azure to complete transactions
    
            Wait -msg "Waiting for Azure" -inSeconds 30 ; Write-Host

            #Remove VNet
            Write-Host -ForegroundColor Yellow "Deleting VNet" -NoNewline
            Remove-AzureVNetConfig -WarningAction SilentlyContinue | Out-Null
            Write-Host -ForegroundColor Green "... Completed" ; Write-Host

            #Pause for Azure to complete transactions

            Wait -msg "Waiting for Azure" -inSeconds 30 ; Write-Host

            # Remove Affinity Group
            Write-Host -ForegroundColor Yellow "Deleting Affinity Group" -NoNewline
            Remove-AzureAffinityGroup -Name SPAutoVNet-AG -WarningAction SilentlyContinue | Out-Null
            Write-Host -ForegroundColor Green "... Completed" ; Write-Host

            Write-Host -ForegroundColor Yellow "Environment Deleted" ; Write-Host

          }
      }
  }

else 
  {
    Write-Host; Write-host -ForegroundColor Yellow -BackgroundColor Red "WARNING:  Choice not recognized. Exiting Script" ; Write-Host
  }

##GP - 06/12/2014
Stop-Transcript | Out-Null