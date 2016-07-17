Configuration FileServer
{
	Import-DscResource -Module PSDesiredStateConfiguration, xSmbShare,cNtfsAccessControl
	
	Node 'MEMBERSRV1'
	{
		File 'Share1Folder'
		{
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = 'C:\FileShare1'
		}
		
		File 'Share2Folder'
		{
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = 'C:\FileShare2'
		}
		
		xSmbShare 'Share1'
		{
			Ensure = 'Present'
			Name   = 'UserShare1'
			Path = 'C:\FileShare1'
			FullAccess = 'Everyone'
			DependsOn = '[File]Share1Folder'
		}
		
		xSmbShare 'Share2'
		{
			Ensure = 'Present'
			Name   = 'UserShare2'
			Path = 'C:\FileShare2'
			FullAccess = 'Everyone'
			DependsOn = '[File]Share2Folder'
		}
		
		cNtfsPermissionEntry 'FileShare1' {
			Ensure = 'Present'
			DependsOn = "[File]Share1Folder"
			Principal = 'Authenticated Users'
			Path = 'C:\FileShare1'
			AccessControlInformation = @(
				cNtfsAccessControlInformation
				{
					AccessControlType = 'Allow'
					FileSystemRights = 'Read'
					Inheritance = 'ThisFolderSubfoldersAndFiles'
					NoPropagateInherit = $false
				}
			)
		}
		
		cNtfsPermissionEntry 'FileShare2' {
			Ensure = 'Present'
			DependsOn = "[File]Share2Folder"
			Principal = 'Authenticated Users'
			Path = 'C:\FileShare2'
			AccessControlInformation = @(
				cNtfsAccessControlInformation
				{
					AccessControlType = 'Allow'
					FileSystemRights = 'Read'
					Inheritance = 'ThisFolderSubfoldersAndFiles'
					NoPropagateInherit = $false
				}
			)
		}
		
	}
}

FileServer -OutputPath C:\
Start-DscConfiguration -Force -Wait -path C:\ -ComputerName MEMBERSRV1 -Verbose
