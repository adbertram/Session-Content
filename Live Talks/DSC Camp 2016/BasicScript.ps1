param (
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string]$FilePath,
	
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[switch]$PassThru
)

## Test to see if the file already exists. If so, I don't want to modify it.
if (Test-Path -Path $FilePath -PathType Leaf)
{
	throw "A file already exists at [$($FilePath)]"
}

## If no file exists, I want to create one and then add a value to it.
$params = @{
	'Path' = $FilePath
	'Value' = 'someimportantvalue'
}

if ($PSBoundParameters.ContainsKey('PassThru')) {
	$params.PassThru = $true
}

$value = Add-Content @params
if ($PassThru.IsPresent)
{
	$value
}