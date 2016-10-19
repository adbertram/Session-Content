#region Intro to DSC

## Scenario #1 - Ensuring a file is present

## With PowerShell -- no validation or logging (GIT 'ER DONE!) bad
$filePath = 'C:\SomeImportFile.txt'
Add-Content -Path $filePath -Value 'Adam deserve a raise --from manager'

## With PowerShell --with validation and logging (alot more code) better

if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Host -Message "The file [$($filePath)] does not exist yet." 
    New-Item -Path $filePath -ItemType File
}

Add-Content -Path $filePath -Value 'Adam deserve a raise --from manager'

if ((Get-Content -Path $filePath -Raw) -match 'Adam deserve a raise --from manager') {
    Write-Host 'The raise file exists!' -ForegroundColor Green
} else {
    Write-Host 'Oh noes! The file could not be created.' -ForegroundColor Red
}

## Run the same code again

## With DSC
configuration CreateTheFile {

    $filePath = 'C:\SomeImportFile.txt'

    Node 'SQLSRV.mylab.local' {
        File 'raisefile' {
            DestinationPath = $filePath
            Contents = 'Adam deserve a raise --from manager'
        }
    }
}

## Execute the configuration to create the node's MOF file
CreateTheFile

## "CreateTheFile" creates a MOF file for the node SQLSRV.mylab.local
ls 'C:\SQLDSC\CreateTheFile'

## Invoke DSC to consume the MOF file which takes over --this creates the file
Start-DscConfiguration -Path .\CreateTheFile -Verbose -Wait -Force

## Run again and it does nothing because the file is already there
Start-DscConfiguration -Path .\CreateTheFile -Verbose -Wait -Force

## Delete the file, run again and the file is back
del C:\SomeImportFile.txt
Start-DscConfiguration -Path .\CreateTheFile -Verbose -Wait -Force

#endregion


## Download the required DSC module

## Run the configuration