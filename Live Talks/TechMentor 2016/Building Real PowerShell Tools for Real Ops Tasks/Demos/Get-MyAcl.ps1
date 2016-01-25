<#
.SYNOPSIS
	This allows an easy method to get a file system access ACE
.PARAMETER Path
 	The file path of a file
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[ValidateScript({ Test-Path -Path $_ })]
	[string]$Path
)

process {
	try {
		(Get-Acl -Path $Path).Access
	} catch {
		Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	}
}