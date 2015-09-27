$script:WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

$script:Clients = @('WINSRV2012R2-2.MYLAB.LOCAL', 'WIN7X64.MYLAB.LOCAL','WIN81-1.MYLAB.LOCAL')

## Reboot all clients
Restart-Computer -ComputerName $Clients -Force
Read-Host 'Rebooting clients.. wait a sec..'

cls

Read-Host 'Did you make the ISE font bigger?'
Read-Host 'Did you make sure all the demo apps are removed from the clients?'

& "$WorkingDir\Cleanup.ps1" -Client $Clients

## Bring up the deployment logs
$Clients | foreach { start "\\$_\c$\windows\temp" }

Get-Process cmtrace -ErrorAction SilentlyContinue | Stop-Process -Force

cls
Write-Host '############ Begin Demo #1 (Deployment Basics and EMET Install) ############' -ForegroundColor Cyan
pause; cls
$script:ServerSideClientDeploymentFolderPath = "$WorkingDir\1. Installs\1. EMET"
$script:ServerModuleFolderPath = "$WorkingDir\DeploymentShare"
$script:ModuleFilePath = "$ServerModuleFolderPath\SoftwareInstallManager.psm1"
$script:ClientDeploymentFolder = 'C:\MyDeployment'
$ClientName = $Clients[0]
$script:Type = 'Install'

## Ensure the deployment folder and the module folder are there
start $ServerSideClientDeploymentFolderPath
start $ServerModuleFolderPath
pause; cls

## Deployment starts - test prereqs first
Write-Host -Message "Testing to ensure the C$ admin share on $ClientName is available" -ForegroundColor Green
Test-Path "\\$ClientName\c$"
pause; cls
Write-Host -Message "Testing to ensure PS remoting on $ClientName is available" -ForegroundColor Green
if (Test-WsMan -ComputerName $ClientName) {
	$true
}
pause; cls

## Show that EMET is not installed
Read-Host 'Is EMET already installed?'

## Create the client deployment folder on the client
$ClientDeploymentFolderName = $ClientDeploymentFolder | Split-Path -Leaf
Write-Host -Message "Creating the client deployment folder $ClientDeploymentFolder on $ClientName" -ForegroundColor Green
if (Test-Path "\\$ClientName\c$\$ClientDeploymentFolderName") {
	Remove-Item "\\$ClientName\c$\$ClientDeploymentFolderName" -Force -Confirm:$false -Recurse
}
$null = mkdir "\\$ClientName\c$\$ClientDeploymentFolderName"

pause; cls

## Copy the deployment files to the client
Write-Host -Message "Copying $ServerSideClientDeploymentFolderPath files to \\$ClientName\c$\$ClientDeploymentFolderName" -ForegroundColor Green
Copy-Item -Path $ServerSideClientDeploymentFolderPath\* -Destination "\\$ClientName\c$\$ClientDeploymentFolderName" -Force
pause; cls

Write-Host -Message "Copying $ServerModuleFolderPath files to \\$ClientName\c$\$ClientDeploymentFolderName" -ForegroundColor Green
Copy-Item -Path $ServerModuleFolderPath\* -Destination "\\$ClientName\c$\$ClientDeploymentFolderName" -Force
pause; cls

## Kick off the script on the client
Write-Host "Executing the deployment script $($Type).ps1 on $ClientName" -ForegroundColor Green
Invoke-Command -ComputerName $ClientName -ScriptBlock { & "$using:ClientDeploymentFolder\$using:Type.ps1" } -AsJob -ThrottleLimit 5
pause; cls

## Wait for the deployment to get done
Write-Host "Waiting for the deployment on $ClientName to complete" -ForegroundColor Green
do {
	Start-Sleep -Seconds 5
} while (Get-Job | Where-Object {$_.State -in @('Running','NotStarted')})
pause; cls

## Clean up the temporary deployment folder copied to the client
Write-Host "Cleaning up the \\$ClientName\c$\$ClientDeploymentFolderName folder" -ForegroundColor Green
Remove-Item -Path "\\$ClientName\c$\$ClientDeploymentFolderName" -Recurse -ErrorAction SilentlyContinue
pause; cls

Read-Host 'Ensure EMET was installed'

## Ensure that the install didn't encounter any errors in the log
ise "$ServerSideClientDeploymentFolderPath\$Type.ps1"
Write-Host '############### End Demo ###############' -ForegroundColor Cyan
Read-Host 'How does the client deployment log look?'

Write-Host '############ Begin Demo #2 (Launch Script Intro) ############' -ForegroundColor Cyan
ise "$WorkingDir\LaunchScript.ps1"
Write-Host '############### End Demo ###############' -ForegroundColor Cyan
pause; cls



function Start-DemoModule {
    param(
        $ModuleName,
        $ServerSideClientDeploymentFolderPath,
        $PreInstallMessage,
        $ExecutionScriptBlock
    )
    Write-Host "############ Begin Demo ($ModuleName Deployment) ############" -ForegroundColor Cyan
    pause; cls
    start $ServerSideClientDeploymentFolderPath
    pause; cls    
    Write-Host $PreInstallMessage -ForegroundColor Green
    Write-Host "Executing -- $($ExecutionScriptBlock.ToString())" -ForegroundColor Cyan
    Read-Host "Let's follow the client install logs as the software is installed"
    & $ExecutionScriptBlock
    Read-Host "Let's check on the app to see if it was installed correctly"
}


$ExecutionTextTemplate = "& `"$WorkingDir\LaunchScript.ps1`" -Client {2} -ServerSideClientDeploymentFolderPath `"{0}`" -Type {1} -Verbose"

$DemoModules = @(
    @{'ModuleName' = 'Adobe Reader Install with EULA'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\2. Adobe Reader"
        'PreInstallMessage' = 'Deploying Adobe Reader'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\2. Adobe Reader",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Adobe Reader Supress Eula Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\2. Adobe Reader"
        'PreInstallMessage' = 'Deploying Adobe Reader'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\2. Adobe Reader",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Cisco AnyConnect Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\3. Cisco AnyConnect"
        'PreInstallMessage' = 'Deploying Cisco AnyConnect'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\3. Cisco AnyConnect",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Web App Shortcut'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\4. Web Apps"
        'PreInstallMessage' = 'Deploying Web App Shortcut'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\4. Web Apps",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Windows Feature Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\5. Windows Features"
        'PreInstallMessage' = 'Deploying Windows Feature'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\5. Windows Features",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Installation Detection'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\1. Installs\6. Installation Detection\Cisco AnyConnect"
        'PreInstallMessage' = 'Detecting Install for Cisco AnyConnect'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\1. Installs\6. Installation Detection\Cisco AnyConnect",'Detect',($Clients -join ',')))
	},
    @{'ModuleName' = 'Web App Shortcut Removal'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\1. Web Apps"
        'PreInstallMessage' = 'Removing web apps shortcut'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\1. Web Apps",'Uninstall',($Clients -join ',')))
    },
    @{'ModuleName' = 'EMET Uninstall'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\2. EMET"
        'PreInstallMessage' = 'Removing EMET'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\2. EMET",'Uninstall',($Clients -join ',')))
    },
    @{'ModuleName' = 'Adobe Reader Uninstall'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\3. Adobe Reader"
        'PreInstallMessage' = 'Removing Adobe Reader'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\3. Adobe Reader",'Uninstall',($Clients -join ',')))
    },
    @{'ModuleName' = 'Cisco AnyConnect Uninstall'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\4. Cisco AnyConnect"
        'PreInstallMessage' = 'Removing Cisco AnyConnnect'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\4. Cisco AnyConnect",'Uninstall',($Clients -join ',')))
    },
     @{'ModuleName' = 'QuickTime Player Install (To Demo Uninstall)'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\5. QuickTime Player"
        'PreInstallMessage' = 'Installing Quicktime Player'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\5. Quicktime Player",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'QuickTime Player (Msizap) Uninstall'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\3. Uninstalls\5. QuickTime Player"
        'PreInstallMessage' = 'Nuking Quicktime Player'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\3. Uninstalls\5. Quicktime Player",'Uninstall',($Clients -join ',')))
    },
    @{'ModuleName' = 'Flash Player Old Version Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\1. Adobe Flash Player"
        'PreInstallMessage' = 'Install Flash Player Old Version'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\1. Adobe Flash Player",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Flash Player Upgrade'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\1. Adobe Flash Player"
        'PreInstallMessage' = 'Upgrading Flash Player'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\1. Adobe Flash Player",'Upgrade',($Clients -join ',')))
    },
    @{'ModuleName' = 'Adobe Reader Old Version Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\2. Adobe Reader"
        'PreInstallMessage' = 'Installing Adobe Reader Old Version'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\2. Adobe Reader\v7",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Adobe Reader Upgrade'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\2. Adobe Reader"
        'PreInstallMessage' = 'Upgrading Adobe Reader'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\2. Adobe Reader",'Upgrade',($Clients -join ',')))
    },
    @{'ModuleName' = 'Java Old versions Install'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\3. Oracle Java"
        'PreInstallMessage' = 'Java Old Versions Old Version'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\3. Oracle Java",'Install',($Clients -join ',')))
    },
    @{'ModuleName' = 'Java Upgrade'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\4. Upgrades\3. Oracle Java"
        'PreInstallMessage' = 'Upgrading Java'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\4. Upgrades\3. Oracle Java",'Upgrade',($Clients -join ',')))
    },
    @{'ModuleName' = 'Misc: User Profile Scripting'
        'ServerSideClientDeploymentFolderPath' = "$WorkingDir\5. Configuration\1. User Profile Scripting"
        'PreInstallMessage' = 'Cleaning up some user profiles'
        'ExecutionScriptBlock' = [scriptblock]::Create(($ExecutionTextTemplate -f "$WorkingDir\5. Configuration\1. User Profile Scripting",'Install',($Clients -join ',')))
    }
)

foreach ($DemoModule in $DemoModules) {
    Start-DemoModule @DemoModule
}