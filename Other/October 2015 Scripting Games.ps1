function Get-RssFeed
{
	[CmdletBinding(DefaultParameterSetName = 'None')]
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