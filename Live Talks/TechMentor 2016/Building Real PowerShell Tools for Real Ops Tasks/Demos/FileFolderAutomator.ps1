function Archive-File {
	<#
    .SYNOPSIS
	    This attempts to recursively search for files in a directory that haven't been accessed in
	    a specified time. Once found, this will move them to an archive location maintaining the same
	    folder structure.
    .PARAMETER FolderPath
 	    The folder path to search for files
    .PARAMETER Age
	    The age of the last time a file has been accessed (in days).
    .PARAMETER ArchiveFolderPath
	    The folder in which the old files will be moved to.
    .PARAMETER Force
	    Use this switch parameter if you'd like to overwrite all files
    #>
    [CmdletBinding()]
    param (
	    [Parameter(Mandatory)]
	    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
	    [string]$FolderPath,
	    [Parameter(Mandatory)]
	    [int]$Age,
	    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
	    [string]$ArchiveFolderPath,
	    [switch]$Force
    )

    process {
	    try {
		    ## Get today's date to find the age later on
            $Today = Get-Date
		    ## Find all files in the folder path that have a LastWriteTime earlier than $Age days ago
            $Files = Get-ChildItem -Path $FolderPath -Recurse -File | where { $_.LastWriteTime -le $Today.AddDays(-$Age) }
            if (-not $Files) {
                Write-Verbose 'No files found to be archived'
            } else {
		        foreach ($File in $Files) {
			        ## Figure out the path to where the file will be archived
                    $DestinationFilePath = $ArchiveFolderPath + ($File.FullName | Split-Path -NoQualifier)
			        Write-Verbose "The file '$($File.FullName)' is older than $Age days.  It will be moved to $DestinationFilePath"
			        ## If the file doesn't already exist in the archive path created a dummy file to create the folder structure
                    if (!(Test-Path -Path $DestinationFilePath -PathType Leaf)) {
				        Write-Verbose "The destination file path $DestinationFilePath does not exist. Archivi."
				        New-Item -ItemType File -Path $DestinationFilePath -Force | Out-Null
			        ## the file exists and -Force was not chosen then skip the file
                    } elseif (!$Force.IsPresent) {
				        Write-Verbose "The file $($File.Fullname) already exists in the archive location and will not be overwritten"
				        continue
			        }
			        Write-Verbose "Moving $($File.FullName) to $DestinationFilePath"
			        ## Move the old file to the archive folder
                    Move-Item -Path $File.FullName -Destination $DestinationFilePath -Force
		        }
            }
	    } catch {
		    Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	    }
    }
}

function Get-MyAcl {
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
}

function Remove-MyAcl {
	<#
    .SYNOPSIS
	    This function allows an easy method to remove file system ACEs
    .PARAMETER Path
 	    The file path of a file
    .PARAMETER Identity
	    The security principal to match with the ACE you'd like to remove.
    #>
    [CmdletBinding()]
    param (
	    [Parameter(Mandatory)]
	    [ValidateScript({ Test-Path -Path $_ })]
	    [string]$Path,
	    [Parameter(Mandatory)]
	    [string]$Identity
    )

    process {
	    try {
		    $Acl = (Get-Item $Path).GetAccessControl('Access')
		    $Acl.Access | where { $_.IdentityReference -eq $Identity } | foreach { $Acl.RemoveAccessRule($_) | Out-Null }
		    Set-Acl -Path $Path -AclObject $Acl
	    } catch {
		    Write-Error  "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	    }
    }
}

function Set-MyAcl {
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
}

function Get-MyFile {
	<#
	.SYNOPSIS
	    This function finds files on all available drives on local or remote computer(s) that match a specified criteria.
        If remote, default admin shares will need to be available.	
	.EXAMPLE
		PS> Get-MyFile -Computername REMOTEPC -Attributes @{'Extension' = 'log'}

        This example finds all available admin shares on REMOTEPC and searches them for all files ending with the extension of .log
	.PARAMETER Computername
        One or more names of a computer to search for files on.  If left blank, this defaults to localhost.
	.PARAMETER Attributes
        A hashtable of file attributes to search for.  Key names can Extension,Age or Name with values representing file extension,
        file age (in days) or file name.  This accepts only a single key/value pair at this time.
	#>
	[CmdletBinding()]
	param (
        [string[]]$Computername = 'localhost',
        [ValidateScript({($_.Keys.Count -eq 1) -and (@('Extension','Age','Name') -like $_.Keys[0])})]
        [hashtable]$Attributes
	)
	process {
		try {
            foreach ($Computer in $Computername) {
	            ## Enumerate all of the default admin shares
                $CimInstParams = @{'ClassName' = 'Win32_Share'}
                if ($Computer -ne 'localhost') {
	                $CimInstParams.Computername = $Computer    
                }
                $DriveShares = (Get-CimInstance @CimInstParams | where { $_.Name -match '^[A-Z]\$$' }).Name
	            foreach ($Drive in $DriveShares) {
		            switch ($Criteria) {
			            'Extension' {
                            Get-ChildItem -Path "\\$Computer\$Drive" -Filter "*.$($Attributes.Extension)" -Recurse
			            }
			            'Age' {
				            $Today = Get-Date
                            $DaysOld = $Attributes.DaysOld
                            Get-ChildItem -Path "\\$Computer\$Drive" -Recurse | Where-Object { $_.LastWriteTime -le $Today.AddDays(-$DaysOld)}
			            }
			            'Name' {
                            $Name = $Attributes.Name
				            Get-ChildItem -Path "\\$Computer\$Drive" -Filter "*$Name*" -Recurse
			            }
                        default {
                            Write-Error "Unrecognized criteria '$Criteria'"
                        }
		            }
	            }
            }
		} catch {
			Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
}