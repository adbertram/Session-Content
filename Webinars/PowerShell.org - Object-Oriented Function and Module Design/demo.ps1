$demoFolder = 'C:\Dropbox\GitRepos\Session-Content\Webinars\PowerShell.org - Object-Oriented Function and Module Design\Demo'

#region Planning --no code yet
<#
1. Define all of my "objects" --these are the modules
 - Garage,Car,Transmission

2. Define the hierarchy --like "inheritance"
 - (Parent module) Garage --> Car (child module) --> Transmission (child module)

3. Define the object "methods"
 - Use CRUD -- New/Get/Set/Remove as a minimum -- common "methods" so "objects" can interact with each other

4. Define properties for each "object". These will be the function parameters
 - ie. A car has a Make, Model and Year and ALWAYS will --mandatory
 - ie. A transmission has a type: Automatic or Manual --mandatory but could have different speed --optional

4. Define how the objects will interact
 - This is expected
  - New-Garage | New-Car -Param1 -Param2 | Set-Car -Param1 -PassThru | New-Transmission -Param1 -Param2

 - This is NOT expected to happen
  - New-Transmission -Param1 -Param2 | New-Garage
#>

## How I design modules/functions
start https://www.gliffy.com/go/html5/9231857?app=1b5094b0-6042-11e2-bcfd-0800200c9a66

#endregion

#region show pre-built modules with a single "parent" manifest
$modules = Get-ChildItem $demoFolder -Filter *.psm1
#endregion

#region Create the "parent" module folder and copy all modules into it along with manifest
$parentModuleFolder = mkdir "$($env:PSModulePath.Split(';')[0])\Garage"

$modules | Copy-Item -Destination $parentModuleFolder.FullName
copy "$demoFolder\Garage.psd1" $parentModuleFolder

#endregion

#region Build the storage to hold our "objects"
$modules | foreach {
    New-Item -Path "$parentModuleFolder\My$($_.BaseName)s.csv" -ItemType File
}

Get-ChildItem $parentModuleFolder

#endregion

Import-Module Garage
Get-Command -Module Garage

$garageParams = @{
	'Address' = '8671 Ash St.'
	'Capacity' = 10
	'FloorType' = 'Concrete'
	'AirConditioned' = $true
}

$carParams = @{
	'Make' = 'BMW'
	'Model' = '328i'
	'Year' = 2015
	'VIN' = '1234567'
}

$transParams = @{
	'SerialNumber' = '12345789333'
	'Type' = 'Automatic'
	'Speed' = 5
}

## Build objects hierarchially
New-Garage @garageParams | New-Car @carParams | New-Transmission @transParams

Get-Car -VIN 1234567
Get-Car -VIN 1234567 | Get-Transmission

Get-Car -VIN 1234567 | Set-Car -Make 'Ford' -PassThru | Get-Transmission
Get-Car -VIN 1234567

#region Module design elements
<# 

Things to note:
1. All functions output a common object type.
2. All parameters are "properties" of that particular "object"/module
3. The module-level variables are shared amongs all function. Sorta like inheritance.
4. Set functions all accept pipeline input
5. Use $InputObject to accept a whole object or give the option of using individual properties

#>

$modules | foreach { ise $_.FullName }
#endregion