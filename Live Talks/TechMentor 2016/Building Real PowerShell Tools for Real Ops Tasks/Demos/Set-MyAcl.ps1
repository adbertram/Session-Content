<#
.SYNOPSIS
	This allows an easy method to set a file system access ACE
.PARAMETER Path
 	The file path of a file
.PARAMETER Identity
	The security principal you'd like to set the ACE to.  This should be specified like
	DOMAIN\user or LOCALMACHINE\User.
.PARAMETER Right
	One of many file system rights.  For a list http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights(v=vs.110).aspx
.PARAMETER InheritanceFlags
	The flags to set on how you'd like the object inheritance to be set.  Possible values are
	ContainerInherit, None or ObjectInherit. http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.inheritanceflags(v=vs.110).aspx
.PARAMETER PropagationFlags
	The flag that specifies on how you'd permission propagation to behave. Possible values are
	InheritOnly, None or NoPropagateInherit. http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.propagationflags(v=vs.110).aspx
.PARAMETER Type
	The type (Allow or Deny) of permissions to add. http://msdn.microsoft.com/en-us/library/w4ds5h86(v=vs.110).aspx
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[ValidateScript({ Test-Path -Path $_ })]
	[string]$Path,
	[Parameter(Mandatory = $true)]
	[string]$Identity,
	[Parameter(Mandatory = $true)]
	[string]$Right,
	[Parameter(Mandatory = $true)]
	[ValidateSet('ContainerInherit','None','ObjectInherit','ContainerInherit,ObjectInherit')]
	[string]$InheritanceFlags,
	[Parameter(Mandatory = $true)]
	[ValidateSet('InheritOnly','None','NoPropagateInherit')]
	[string]$PropagationFlags,
	[Parameter(Mandatory = $true)]
	[ValidateSet('Allow','Deny')]
	[string]$Type
)

process {
	try {
		$Acl = (Get-Item $Path).GetAccessControl('Access')
		$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Identity, $Right, $InheritanceFlags, $PropagationFlags, $Type)
		$Acl.SetAccessRule($Ar)
		Set-Acl $Path $Acl
	} catch {
		Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	}
}