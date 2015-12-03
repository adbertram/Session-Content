[CmdletBinding()]

param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$XmlFilePath,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$ServerInstance,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Database,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$UserName,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Password,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$Query,
	
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$XmlConversionScriptFilePath = 'C:\IpswitchDemo\ConvertDataRow-ToXml.ps1' ## Use this script for other purposes as well
)

Import-Module SQLPS

#region Query the database and gather all rows from the table

$params = @{
	'Database' = $Database
	'ServerInstance' = $ServerInstance
	'Username' = $UserName
	'Password' = $Password
	'OutputSqlErrors' = $true
	'Query' = $Query
}
Write-Output "Querying the database [$($Database)] on server instance [$($ServerInstance)]"
$sqlRows = Invoke-Sqlcmd @params

#endregion

#region Run the conversion script
## Dot source the conversion script to make the function inside usable
. $XmlConversionScriptFilePath

## Create the XML file from the Azure SQL table 'Users'  The ObjectType is the object template that all rows in the Azure SQL table are. ie. In this example,
## I have a table of user information, object type is User.
Write-Output "Converting [$($sqlRows.Count)] rows into the XML file [$($XmlFilePath)]"
$xmlFile = $sqlRows | ConvertDataRow-ToXml -ObjectType User -Path $XmlFilePath

## Show an error in the MOVEit debug log if the number of users in the XML doesn't match the database
if ($sqlRows.Count -ne (([xml](Get-Content -Path $xmlFile.FullName)).Users.User.Count))
{
	$Host.SetShouldExit(1)
}
else
{
	Write-Output 'Conversion successful!'	
}
