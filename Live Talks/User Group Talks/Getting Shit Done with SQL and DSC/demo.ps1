#region Intro to DSC

## Scenario #1 - Ensuring a file is present with something in it

## With PowerShell -- no validation or logging (GIT 'ER DONE!) bad
$filePath = 'C:\SomeImportFile.txt'
Add-Content -Path $filePath -Value 'Adam deserve a raise --from manager'
Get-Content -Path $filepath
del $filepath

## With PowerShell --with validation and logging (alot more code) better

if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Host -Message "The file [$($filePath)] does not exist yet." 
    $null = New-Item -Path $filePath -ItemType File
}

Add-Content -Path $filePath -Value 'Adam deserve a raise --from manager'

if ((Get-Content -Path $filePath -Raw) -match 'Adam deserve a raise --from manager') {
    Write-Host 'The raise file exists!' -ForegroundColor Green
} else {
    Write-Host 'Oh noes! The file could not be created.' -ForegroundColor Red
}

## Run the same code again --PowerShell is dumb
Get-Content -Path $filePath

## With DSC

## Use the built-in File resource
Get-DscResource File -Syntax

#region Create the configuration
configuration CreateTheFile {

    $filePath = 'C:\SomeImportFile.txt'

    Node 'SQLSRV.mylab.local' {
        File 'raisefile' {
            DestinationPath = $filePath
            Contents = 'Adam deserve a raise --from manager'
        }
    }
}
#endregion

#region Execute the configuration to create the node's MOF file
CreateTheFile
ls '.\CreateTheFile'
gc .\CreateTheFile\SQLSRV.mylab.local.mof
#endregion

## Invoke DSC to consume the MOF file which takes over --this ensures the file is there and contents
## no change. looks good
Start-DscConfiguration -Path .\CreateTheFile -Verbose -Wait -Force

## change the contents a little
Set-Content -Path $filePath -Value 'whatever' -PassThru
gc $filepath

## Run again and it does nothing because the file is already there
Start-DscConfiguration -Path .\CreateTheFile -Verbose -Wait -Force

## Check again
gc $filePath

#endregion

#region SQL


## no SQL server resource by default
Get-DscResource

## find one from the PowerShell Gallery
$resource = Find-Module xSqlServer
$resource

## install it
$resource | Install-Module

$InstallerServiceAccount = Get-Credential -UserName 'mylab.local\administrator' -Message 'Input credentials for installing SQL Server'

## Make the confiugration available
. .\SqlServer.ps1

## Run the configuration which creates the MOF
SQLStandalone -ConfigurationData "$PSScriptRoot\ConfigurationData.psd1" -SetupCredential $InstallerServiceAccount

## The configuration was created from combining "configuration data" with the actual configuration. This allows you to
## separate out per-server values from the configuration to share configurations.

## DSC takes over
Start-DscConfiguration -Path .\SQLStandalone -Verbose -Wait -Force

#endregion

### BENEFITS OF DSC ###
<#
1. No if/then logic in code. Just state what you want and DSC does the rest.
2. A lot less code all together.
3. No need to remember complicated install switches.
4. Leverage lots of existing resources via PowerShell Gallery
#>
