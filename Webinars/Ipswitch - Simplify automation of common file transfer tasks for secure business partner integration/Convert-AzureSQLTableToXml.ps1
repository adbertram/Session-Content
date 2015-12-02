#Requires -Module SQLPS

[CmdletBinding()]

param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$XmlFilePath,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$XmlConversionScriptFilePath = 'C:\IpswitchDemo\ConvertDataRow-ToXml.ps1', ## Use this script for other purposes as well
	
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
	[string]$Query
)

#region Query the database and gather all rows from the table

$params = @{
	'Database' = $Database
	'ServerInstance' = $ServerInstance
	'Username' = $UserName
	'Password' = $Password
	'OutputSqlErrors' = $true
	'Query' = $Query
}
$sqlRows = Invoke-Sqlcmd @params

#endregion

#region Run the conversion script
## Dot source the conversion script to make the function inside usable
. $XmlConversionScriptFilePath

## Create the XML file from the Azure SQL table 'Users'  The ObjectType is the object template that all rows in the Azure SQL table are. ie. In this example,
## I have a table of user information, object type is User.
$sqlRows | ConvertDataRow-ToXml -ObjectType User -Path $XmlFilePath