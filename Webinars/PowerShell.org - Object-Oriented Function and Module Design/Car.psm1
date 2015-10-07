$DataSource = 'C:\Cars.csv'

function Get-Car
{
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
		
	)
	begin {
		$ErrorActionPreference = 'Stop'
	}
	process {
		try
		{
			echo $DataSource		
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
}