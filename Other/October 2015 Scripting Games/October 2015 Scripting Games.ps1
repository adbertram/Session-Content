#requires -Version 3

function Get-RssFeed
{
	<#
	.SYNOPSIS
		This function retrieved items from a RSS feed.

	.DESCRIPTION
		This function attempts to read all items that exist in a RSS feed. If found, it will then output a standard set
		of attributes about each item that provide a useful representation of the contents of each item.

	.PARAMETER Uri
		This is the Uri or Url of the feed that you'd like to query. It must be a valid URL.

	.PARAMETER Author
		Use this parameter if you'd like to limit the items shown by the author name. This parameter will match the creator
		field in the XML file returned.
	
	.PARAMETER Newest
		Input a number here to specify the newest X number of items returned. This will only display the latest X items by the 
		PubDate element in the XML file returned. This parameter cannot be used in conjunction with the Oldest parameter.
	
	.PARAMETER Oldest
		Input a number here to specify the oldest X number of items returned. This will only display the oldest X items by the 
		PubDate element in the XML file returned. This parameter cannot be used in conjunction with the Newest parameter.

	.EXAMPLE
		Get-RssFeed -Uri 'http://www.adamtheautomator.com/feed'
	
		This example will query the Adam, the Automator blog for all RSS items and return them all.

	.EXAMPLE
		Get-RssFeed -Uri 'http://www.adamtheautomator.com/feed' -Newest 5
	
		This example will query the Adam, the Automator blog for and only display the latest 5 items based on published date.

	.INPUTS
		System.String

	.OUTPUTS
		System.Management.Automation.PSCustomObject
	
	#>
	
	[CmdletBinding(DefaultParameterSetName = 'None')]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param
	(
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[ValidatePattern('^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')]
		[string]$Uri,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Author,
	
		[Parameter(ParameterSetName = 'Newest')]
		[ValidateNotNullOrEmpty()]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Newest,
	
		[Parameter(ParameterSetName = 'Oldest')]
		[ValidateNotNullOrEmpty()]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Oldest
		
	)
	begin {
		$ErrorActionPreference = 'Stop'
	}
	process {
		try
		{
			Write-Verbose -Message "Attempting to download content from URI [$$Uri]..."
			$result = Invoke-WebRequest -Uri $Uri
			if ($result.StatusCode -ne 200)
			{
				throw "The web request to [$Uri] failed with status code [$($result.StatusCode)]"
			}
			Write-Verbose -Message 'Download was successful.'
			$xRss = [xml]$result
			
			if (-not $xRss.rss.channel.item)
			{
				Write-Warning 'No RSS items found'
			}
			else
			{
				$sortParams = @{ 'Property' = 'PublishDate' }
				$selectParams = @{ 'Property' = '*' }
				if ($PSBoundParameters.ContainsKey('Newest'))
				{
					$sortParams.Descending = $true
					$selectParams.First = $Newest
				}
				if ($PSBoundParameters.ContainsKey('Oldest'))
				{
					$selectParams.First = $Oldest
				}
				if ($PSBoundParameters.ContainsKey('Author')) {
					$whereBlock = { $_.creator.innertext -eq $Author }
				}
				else
				{
					$whereBlock = {$_}	
				}
				
				$selCalcProps = @{
					'Property' = '*', @{ n = 'PublishDate'; e = { [DateTime]$_.PubDate } }
					'ExcludeProperty' = 'PubDate'
				}
				$items = $xRss.rss.channel.item | Select-Object @selCalcProps | Where-Object $whereBlock | Sort-Object @sortParams | Select-Object @selectParams
				foreach ($x in $items)
				{
					$output = @{ }
					$output.Author = $x.creator.innertext
					$output.Title = $x.title
					$output.ItemLink = $x.link
					$output.CommentsLink = $x.comments[0]
					$output.CommentCount = $x.comments[1]
					$output.Category = $x.category.innertext -join ','
					$output.PublishDate = $x.PublishDate
					[pscustomobject]$output
				}
			}
		}
		catch
		{
			Write-Error "$($_.Exception.Message) - $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
}