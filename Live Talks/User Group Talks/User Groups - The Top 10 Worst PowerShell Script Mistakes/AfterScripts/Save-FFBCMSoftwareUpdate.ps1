function Save-FFBCMSoftwareUpdate
{
	<#
	.Synopsis
	    Saves update files to the software update package specified
	.DESCRIPTION
	    The Save-FFBCMSoftwareUpdate saves the software update file to the specified software update package.
	.EXAMPLE
	    $params = @{
			'DeploymentPackageName' =  'Server - 2012'
			'SoftwareUpdateId' = '16782778'
			'SiteServer' = 'SCCM'
			'SiteCode' = 'CM1'
		}
		PS> Save-FFBCMSoftwareUpdate @params
	
		This example will do something really cool.
	.PARAMETER DeploymentPackageName
	    Name of the Software Update Package
	.PARAMETER SoftwareUpdateId
	    ID of the Software Update (CI_ID)
	.PARAMETER SiteServer
	    Name of ConfigMgr Site Server
	.PARAMETER SiteCode
	    ConfigMgr Site Code
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[string]$DeploymentPackageName,
		
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$SoftwareUpdateId,
		
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
		[string]$SiteServer,
		
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[ValidatePattern('^\w{3}$')]
		[string]$SiteCode
		
	)
	process
	{
		try
		{
			$wmiCmParams = @{
				'ComputerName' = $SiteServer
				'NameSpace' = "root\sms\site_$SiteCode"
			}
			
			$deploymentPackagePath = (Get-CMDeploymentPackagePath -Name $DeploymentPackageName -SiteServer $SiteServer -SiteCode $SiteCode)
			
			$softwareUpdatePackage = Get-WmiObject @wmiCmParams -Class 'SMS_SoftwareUpdatesPackage' -Filter "Name='$DeploymentPackageName'"
			
			#Only Download English and updates that are not targeted to a specific language
			$contentLocales = "'Locale:0','Locale:9'"
			
			$driveLetter = 'M'
			if (-not (Get-PSDrive -Name $driveLetter))
			{
				Write-Verbose -Message "Creating the PS drive [$($driveLetter)]"
				$null = New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $deploymentPackagePath
			}
			
			#Redefine deploymentPackagePath to strip off FileSystem::
			## I don't like thi but I don't know what this does - ADB
			$deploymentPackagePath = $deploymentPackagePath -replace ('FileSystem::', '')
			
			#Build Hash Table to store update info that we need to mark the update as downloaded
			## ADB - This is bad practice to bring all the output into an array and then output it.  It takes up more memory
			## instead of outputting each object one at a time.
			
			Write-Verbose "Attempting to resolve content location for Update ID: $SoftwareUpdateId"
			$params = $wmiCmParams + @{
				'Query' = "SELECT ContentID,ContentUniqueID,ContentLocales FROM SMS_CIToContent WHERE CI_ID='$SoftwareUpdateId' AND ContentLocales in ($contentLocales)"
			}
			$content = Get-WmiObject @params
			
			$updateQueryTemplate = "select SMS_PackageToContent.ContentID,SMS_PackageToContent.PackageID from SMS_SoftwareUpdate
                            join SMS_CIToContent on SMS_CIToContent.CI_ID = SMS_SoftwareUpdate.CI_ID
                            join SMS_PackageToContent on SMS_CIToContent.ContentID = SMS_PackageToContent.ContentID
                            where SMS_PackageToContent.PackageID = '{0}'
                            and SMSPackageToContent.ContentID = '{1}'"
			
			foreach ($c in $content)
			{
				Write-Verbose "This content is for locale: $($c.ContentLocales)"
				$updateQuery = $updateQueryTemplate
				$updateQuery = $updateQuery -f $softwareUpdatePackage.PackageID, $c.ContentID
				Write-Verbose -Message "Using update query [$($updateQuery)]"
				
				$contentInfo = Get-WmiObject @wmiCmParams -Query $updateQuery
				if (-not $contentInfo)
				{
					Write-Verbose -Message 'Content info was not found'
					$contentFile = Get-WmiObject @wmiCmParams -Filter "ContentID='$($c.ContentID)'"
					$dest = "M:\$($c.ContentUniqueID)\$($contentFile.FileName)"
					If (-not (Test-Path -Path $dest -PathType Container))
					{
						$null = New-Item -ItemType directory -Path $dest
						Write-Verbose "Directory [$($dest)] was not found. Creating..."
					}
					Write-Verbose -Message "Start BITS transfer from [$($contentFile.SourceURL)] to [$($dest)]"
					Start-BitsTransfer -Source $contentFile.SourceURL -Destination $dest
					Write-Verbose -Message 'Transfer complete'
					
					Write-Verbose -Message "Adding content to [$($softwareUpdatePackage.Name)]"
					If ($SoftwareUpdatePackage.AddUpdateContent($c.ContentID, $deploymentPackagePath, $false).ReturnValue -eq 0)
					{
						Write-Verbose "Successfully added content to $($SoftwareUpdatePackage.Name)"
					}
					Else
					{
						Write-Warning "Unable to add content to $($SoftwareUpdatePackage.Name)"
					}
				}
				else
				{
					Write-Warning "Content has already been downloaded for Update ID: $SoftwareUpdateId"
				}
			}
		}
		catch
		{
			Write-Error $_.Exception.Message	
		}
	}
}