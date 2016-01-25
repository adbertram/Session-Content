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