## For the demonstration to work correctly several pieces of software need to be loaded onto the MOVEit Central server
## to work properly.  This script will download and install all of them.

#region Download and install all prereqs

## All required installers and the URLs they are located at
$files = [ordered]@{
	'SQLSysClrTypes.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409' # Microsoft® System CLR Types for Microsoft® SQL Server® 2012 (x64)
	'SharedManagementObjects.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239659&clcid=0x409' # Microsoft® SQL Server® 2012 Shared Management Objects (x64)
	'PowerShellTools.msi' = 'http://go.microsoft.com/fwlink/?LinkID=239656&clcid=0x409' # Microsoft® Windows PowerShell Extensions for Microsoft® SQL Server® 2012 (x64)
}

#region Create the download folder
$downloadFolder = 'C:\IpswitchDemo'
if (-not (Test-Path -Path $downloadFolder -PathType Container))
{
	$null = mkdir -Path $downloadFolder
}
#endregion

#region Download each file and, if an installer, then execute it silently with msiexec.exe
foreach ($file in $files.GetEnumerator())
{
	$downloadFile = (Join-Path -Path $downloadFolder -ChildPath $file.Key)
	Invoke-WebRequest -Uri $file.Value -OutFile $downloadFile
	if ([System.IO.Path]::GetExtension($downloadFile) -eq '.msi')
	{
		Start-Process -FilePath 'msiexec.exe' -Args "/i $downloadFile /qn ALLUSERS=1" -Wait
	}
}
#endregion

#region Move the SQLPS module to the system-level module path (MOVEit will look inside this when execting the task)

Move-Item -Path 'C:\Program Files\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS' -Destination 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules'

#endregion