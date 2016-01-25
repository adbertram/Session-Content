[CmdletBinding()]
param(
    $RootHomeFolder = '\\labdc.lab.local\c$\usershomefolder',
    $Age,
    $ArchiveFolderPath = 'C:\ArchivedStuff',
    $FullPermissionGroup = 'administrators'
)
. C:\FileFolderAutomator.ps1

## Find the total file count of all files in the archived location before the move
Write-Verbose 'Finding the archive file count before the archival process...'
$ArchiveFileCountBefore = (Get-ChildItem -Path $ArchiveFolderPath -Recurse -File).Count
Write-Verbose 'Done'

## Archive all user files in all home folders
Write-Verbose 'Beginning the archival process...'
Archive-File -FolderPath $RootHomeFolder -Age $Age -ArchiveFolderPath $ArchiveFolderPath -Verbose
Write-Verbose 'Done'

## Find the total file count of all files in the archived location after the move
Write-Verbose 'Finding the archive file count after the archival process...'
$AfterArchivedFiles = Get-ChildItem -Path $ArchiveFolderPath -Recurse -File
$ArchiveFileCountAfter = $AfterArchivedFiles.Count
Write-Verbose 'Done'
Write-Verbose "Archived a total of [$($ArchiveFileCountAfter - $ArchiveFileCountBefore)] files"

## Ensure the local system's admnistrators group has full control over all files in the archive folder path
Write-Verbose 'Begin ACL change process'
foreach ($File in $AfterArchivedFiles) {
    Set-MyAcl -Path $File.FullName -Identity $FullPermissionGroup -Right 'FullControl' -InheritanceFlags None -PropagationFlags None -Type Allow
}
Write-Verbose 'Done'