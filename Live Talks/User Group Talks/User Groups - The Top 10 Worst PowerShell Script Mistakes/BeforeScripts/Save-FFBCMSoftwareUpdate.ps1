function Save-FFBCMSoftwareUpdate
{
	<#
	.Synopsis
	    Saves update files to the software update package specified
	.DESCRIPTION
	    The Save-FFBCMSoftwareUpdate saves the software update file to the specified software update package.
	.EXAMPLE
	    Save-FFBCMSoftwareUpdate -DeploymentPackageName "Server - $UpdateGroupYear" -SoftwareUpdateId '16782778' -SiteServer 'sccm' -SiteCode 'CM1'
	.PARAMETER DeploymentPackageName
	    Name of the Software Update Package
	.PARAMETER SoftwareUpdateId
	    ID of the Software Update (CI_ID)
	.PARAMETER SiteServer
	    Name of ConfigMgr Site Server
	.PARAMETER SiteCode
	    ConfigMgr Site Code
	#>
	[CmdletBinding(SupportsShouldProcess = $true,
				   PositionalBinding = $false)]
	Param (
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$DeploymentPackageName,
		
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$SoftwareUpdateId,
		
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$SiteServer,
		
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 3)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$SiteCode
	)
	
	$deploymentPackagePath = (Get-CMDeploymentPackagePath -Name $DeploymentPackageName -SiteServer $SiteServer -SiteCode $SiteCode)
	$softwareUpdatePackage = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Class SMS_SoftwareUpdatesPackage -Filter "Name='$DeploymentPackageName'"
	
	#Only Download English and updates that are not targeted to a specific language
	$contentLocales = "'Locale:0','Locale:9'"
	
	New-PSDrive -Name M -PSProvider FileSystem -Root $deploymentPackagePath | Out-Null
	
	#Redefine deploymentPackagePath to strip off FileSystem::
	$deploymentPackagePath = $deploymentPackagePath -replace ('FileSystem::', '')
	
	#Build Hash Table to store update info that we need to mark the update as downloaded
	$downloadInfo = @()
	$updateInfo = @()
	
	Write-Verbose "Attempting to resolve content location for Update ID: $SoftwareUpdateId"
	$content = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT ContentID,ContentUniqueID,ContentLocales FROM SMS_CIToContent WHERE CI_ID='$SoftwareUpdateId' AND ContentLocales in ($contentLocales)"
	
	foreach ($c in $content)
	{
		Write-Verbose "This content is for locale: $($c.ContentLocales)"
		$updateQuery = "select SMS_PackageToContent.ContentID,SMS_PackageToContent.PackageID from SMS_SoftwareUpdate
                            join SMS_CIToContent on SMS_CIToContent.CI_ID = SMS_SoftwareUpdate.CI_ID
                            join SMS_PackageToContent on SMS_CIToContent.ContentID = SMS_PackageToContent.ContentID
                            where SMS_PackageToContent.PackageID = '$($softwareUpdatePackage.PackageID)'
                            and SMSPackageToContent.ContentID = '$($c.ContentID)'"
		$contentInfo = @(Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -Query $updateQuery -ErrorAction SilentlyContinue)
		if (-not ($contentInfo))
		{
			$contentFile = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT FileName,SourceURL FROM SMS_CIContentFiles WHERE ContentID='$($c.ContentID)'"
			$downloadInfo += [PSCustomObject]@{ Source = $contentFile.SourceURL; Destination = "M:\$($c.ContentUniqueID)\$($contentFile.FileName)"; }
			$updateInfo += [PSCustomObject]@{ ContentID = $($c.ContentID); SourcePath = $deploymentPackagePath; }
		}
		else
		{
			Write-Warning "Content has already been downloaded for Update ID: $SoftwareUpdateId"
		}
	}
	
	#Test and create the Destination Folders if needed
	If ($downloadInfo)
	{
		$downloadInfo.destination | ForEach-Object -Process {
			If (-not (Test-Path -Path "$(Split-Path -Path $_)"))
			{
				New-Item -ItemType directory -Path "$(Split-Path -Path $_)" | Out-Null
				Write-Verbose "Creating Directory $_"
			}
		}
		
		#Download the update
		$downloadInfo | Start-BitsTransfer
		
		#Add downloaded update to Deployment Package and refresh distribution points
		If ($SoftwareUpdatePackage.AddUpdateContent($($updateInfo.ContentID), $($updateInfo.SourcePath), $false).ReturnValue -eq 0)
		{
			Write-Verbose "Successfully added content to $($SoftwareUpdatePackage.Name)"
		}
		Else
		{
			Write-Warning "Unable to add content to $($SoftwareUpdatePackage.Name)"
		}
	}
}