[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string]$Name,

	[Parameter(Mandatory)]
	[string]$Manufacturer,

	[Parameter(Mandatory)]
	[ValidatePattern('[-+]?([0-9]*\.[0-9]+|[0-9]+)')]
	[string]$SoftwareVersion,
	
	[Parameter(Mandatory)]
	[ValidateScript({ Test-Path -Path $_ -PathType Container })]
	[string]$SourceFolderPath,
	
	[Parameter()]
	[string]$InstallationProgram = 'install.ps1',
	
	[Parameter()]
	[string]$UninstallProgram = 'uninstall.ps1',
	
	[Parameter()]
	[switch]$Distribute,
	
	[Parameter()]
	[string]$Owner = 'Adam Bertram',

	[Parameter()]
	[string]$SupportContact = 'Adam Bertram',
	
	[Parameter()]
	[ValidateScript({ Test-Path -Path $_ -PathType Container })]
	[string]$RootPackageFolderPath = '\\MEMBERSRV1\Packages',

	[Parameter()]
	[ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
	[string]$IconLocationFilePath,

	[Parameter()]
	[string]$InstallationBehaviorType = 'InstallForSystem',

	[Parameter()]
	[string]$InstallationProgramVisibility = 'Hidden',

	[Parameter()]
	[string]$MaximumAllowedRunTimeMinutes = '15',

	[Parameter()]
	[string]$EstimatedInstallationTimeMinutes = '5',

	[Parameter()]
	[string]$RebootBehavior = 'ForceReboot',

	[Parameter()]
	[string]$DistributionPointGroup = 'DP Group',

	[Parameter()]
	[string]$SiteCode = 'LAB'
)

begin {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
	Set-StrictMode -Version Latest
	try {
        #region Verify the ConfigurationManager module is available
        Write-Verbose 'Ensuring the ConfigurationManager module is available and importing it...'
		## Ensure the ConfigurationManager module is available
		if (!(Test-Path "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1")) {
			throw 'Configuration Manager module not found.  Is the admin console intalled?'
		} elseif (!(Get-Module 'ConfigurationManager')) {
			Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
		}
        #endregion

		Write-Verbose 'Performing prereq setup things...'
		
        #region Standardize the folder package names
		## Replace any spaces in the attributes with backspaces
		$PackageFolderName = "$($Manufacturer.Replace(' ','_'))_$($Name.Replace(' ','_'))_$($SoftwareVersion.Replace(' ','_'))"
		$ContentFolderPath = "$RootPackageFolderPath\$PackageFolderName"
        #endregion

	} catch {
		Write-Error $_.Exception.Message
	}
}

process {
	try
	{
		#region Content folder creation
        ## Create the source folder path to place the source content then copy all of the contents
		## from the original source folder to the package source folder.
		Write-Verbose "Creating the content folder '$ContentFolderPath'..."
		if (!(Test-Path $ContentFolderPath))
		{
			mkdir $ContentFolderPath | Out-Null
		}
		else
		{
			throw "The folder at '$ContentFolderPath' already exists."
		}
        #endregion
		
		#region Copy source content to the content folder
		Write-Verbose "Copying files from source folder '$SourceFolderPath' to '$ContentFolderPath'..."
		Copy-Item -Path "$SourceFolderPath\*" -Destination $ContentFolderPath -Recurse -Force
<<<<<<< HEAD
        #endregion		

		#region Create the application container.  This will hold our deployment type
=======
		
		## Copy the script templates (import-module, $workingdir, start-log, etc)
		Write-Verbose "Copying the template files at '$ScriptTemplateFilePath' to '$ContentFolderPath'..."
		@('detect', 'install', 'uninstall') | foreach {
			Copy-Item -Path $ScriptTemplateFilePath -Destination "$ContentFolderPath\$($_).ps1"
		}
		
		## Create the application container.  This will hold our deployment type
>>>>>>> parent of 4ef98ea... updates
		Write-Verbose "Creating the application '$Name'..."
		$NewCmApplicationParams = @{
			'Name' = $Name;
			'Owner' = $Owner;
			'SupportContact' = $SupportContact;
			'Publisher' = $Manufacturer;
			'SoftwareVersion' = $SoftwareVersion
		}
		if ($PSBoundParameters.ContainsKey('IconLocationFilePath'))
		{
			$NewCmApplicationParams.IconLocationFile = $IconLocationFilePath
		}
		Push-Location "$($SiteCode):" -StackName $SiteCode
		New-CMApplication @NewCmApplicationParams | Out-Null
		Pop-Location -StackName $SiteCode
	    #endregion	
    
		#region Create the deployment type
		Write-Verbose 'Creating the deployment type...'
		$AddCmDeploymentTypeParams = @{
			'ApplicationName' = $Name;
			'ScriptInstaller' = $true;
			'ManualSpecifyDeploymentType' = $true;
			'DeploymentTypeName' = "Deploy $Name";
			'InstallationProgram' = $InstallationProgram;
			'UninstallProgram' = $UninstallProgram
			'ContentLocation' = $ContentFolderPath;
			## TODO: This param is ignored
			##'LogonRequirementType' = 'WhereOrNotUserLoggedOn';
			'InstallationBehaviorType' = $InstallationBehaviorType;
			'InstallationProgramVisibility' = $InstallationProgramVisibility;
			'MaximumAllowedRunTimeMinutes' = $MaximumAllowedRunTimeMinutes;
			'EstimatedInstallationTimeMinutes' = $EstimatedInstallationTimeMinutes;
			'DetectDeploymentTypeByCustomScript' = $true;
			'ScriptType' = 'PowerShell';
			'ScriptContent' = ((Get-Content -Path "$ContentFolderPath\detect.ps1") -join "`r`n")
		}
		Push-Location "$($SiteCode):" -StackName $SiteCode
		Add-CMDeploymentType @AddCmDeploymentTypeParams
        #endregion		

		#region Set reboot behavior because it can't be set with Add-CMDeploymentType
		Write-Verbose 'Setting reboot behavior for the deployment type...'
		$SetCmDeploymentTypeParams = @{
			'RebootBehavior' = $RebootBehavior;
			'DeploymentTypeName' = "Deploy $Name";
			'ApplicationName' = $Name;
			'MsiOrScriptInstaller' = $true;
		}
		Set-CMDeploymentType @SetCmDeploymentTypeParams
        #endregion
		
		#region distribute to DPs
		if ($PSBoundParameters.ContainsKey('Distribute')) {
			Write-Verbose 'Distributing content...'
			$cdParams = @{
				'ApplicationName' = $Name
				'DistributionPointGroupName' = $DistributionPointGroup
			}
			Start-CMContentDistribution @cdParams
		}
        #endregion
		
		
		## Create the OSD package
#		Write-Verbose 'Creating the OSD package...'
#		$PackageConversionScriptFilePath = 'C:\Dropbox\Powershell\scripts\complete\Convert-CMApplicationToPackage.ps1'
#		if (Test-Path $PackageConversionScriptFilePath) {
#			& $PackageConversionScriptFilePath -ApplicationName $Name -SkipRequirements -DistributeContent -OsdFriendlyPowershellSyntax
#		} else {
#			Write-Warning "OSD package could not be created because the script '$PackageConversionScriptFilePath' does not exist"
#		}
		
		Write-Verbose 'Done.'
	} catch {
		Write-Error $_.Exception
		exit
	}
	finally
	{
		Pop-Location -StackName $SiteCode -ea Ignore
	}
}