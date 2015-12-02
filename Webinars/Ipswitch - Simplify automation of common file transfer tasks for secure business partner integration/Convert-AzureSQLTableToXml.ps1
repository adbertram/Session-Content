[CmdletBinding()]

param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$XmlFilePath
)




#region Query the database

$params = @{
	'Database' = 'myazuredatabase'
	'ServerInstance' = 'adamazuresql.database.windows.net'
	'Username' = 'adam'
	'Password' = 'p@$$w0rd12'
	'OutputSqlErrors' = $true
	'Query' = 'SELECT * FROM Users'
}
Invoke-Sqlcmd @params

#endregion