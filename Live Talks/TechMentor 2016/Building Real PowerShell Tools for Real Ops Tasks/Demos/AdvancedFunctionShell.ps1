function New-AdvancedFunction {
	<#
	.SYNOPSIS
		
	.EXAMPLE
		PS> New-AdvancedFunction -Param1 MYPARAM

        This example does something to this and that.
	.PARAMETER Param1
        This param does this thing.
	.PARAMETER 
	.PARAMETER 
	.PARAMETER 
	#>
	[CmdletBinding()]
	param (
        [string]$Param1
	)
	process {
		try {
	
		} catch {
			Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
}

