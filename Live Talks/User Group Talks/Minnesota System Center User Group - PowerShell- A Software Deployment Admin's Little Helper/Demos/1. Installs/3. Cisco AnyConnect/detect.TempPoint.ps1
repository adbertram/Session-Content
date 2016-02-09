Import-Module \\configmanager\deploymentmodules\SoftwareInstallManager -DisableNameChecking
Start-Log

## Check if all software was installed
$SoftwareToValidate = @(
	@{ 'Title' = 'Cisco AnyConnect Diagnostics and Reporting Tool'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Network Access Manager'; 'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco AnyConnect Secure Mobility Client';  'Version' = '3.1.05182' },
	@{ 'Title' = 'Cisco NAC Agent';  'Version' = '4.9.4.3' }
)
foreach ($Title in $SoftwareToValidate) {
	if (!(Validate-IsSoftwareInstalled -ProductName $Title.Title -Version $Title.Version)) {
		exit
	}
}

## Check if the configuration file got copied properly
function Get-FileHash {
	##############################################################################
	##
	## Get-FileHash
	##
	## From Windows PowerShell Cookbook (O'Reilly)
	## by Lee Holmes (http://www.leeholmes.com/guide)
	##
	##############################################################################
	
	<#
	.SYNOPSIS

	Get the hash of an input file.

	.EXAMPLE

	Get-FileHash myFile.txt
	Gets the hash of a specific file

	.EXAMPLE

	dir | Get-FileHash
	Gets the hash of files from the pipeline

	.EXAMPLE

	Get-FileHash myFile.txt -Hash SHA1
	Gets the has of myFile.txt, using the SHA1 hashing algorithm

	#>
	
	param (
		## The path of the file to check
		$Path,
		## The algorithm to use for hash computation
		[ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
		$HashAlgorithm = "MD5"
	)
	
	Set-StrictMode -Version Latest
	
	## Create the hash object that calculates the hash of our file.
	$hashType = [Type] "System.Security.Cryptography.$HashAlgorithm"
	$hasher = $hashType::Create()
	
	## Create an array to hold the list of files
	$files = @()
	
	## If they specified the file name as a parameter, add that to the list
	## of files to process
	if ($path) {
		$files += $path
	}
	## Otherwise, take the files that they piped in to the script.
	## For each input file, put its full name into the file list
	else {
		$files += @($input | Foreach-Object { $_.FullName })
	}
	
	## Go through each of the items in the list of input files
	foreach ($file in $files) {
		## Skip the item if it is not a file
		if (-not (Test-Path $file -Type Leaf)) { continue }
		
		## Convert it to a fully-qualified path
		$filename = (Resolve-Path $file).Path
		
		## Use the ComputeHash method from the hash object to calculate
		## the hash
		$inputStream = New-Object IO.StreamReader $filename
		$hashBytes = $hasher.ComputeHash($inputStream.BaseStream)
		$inputStream.Close()
		
		## Convert the result to hexadecimal
		$builder = New-Object System.Text.StringBuilder
		$hashBytes | Foreach-Object { [void] $builder.Append($_.ToString("X2")) }
		
		## Return a custom object with the important details from the
		## hashing
		$output = New-Object PsObject -Property @{
			Path = ([IO.Path]::GetFileName($file));
			HashAlgorithm = $hashAlgorithm;
			HashValue = $builder.ToString()
		}
		
		$output
	}
}

$WinXpPath = "$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco AnyConnect Secure Mobility Client\Network Access Manager\system\configuration.xml"
$Win7Path = "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco AnyConnect Secure Mobility Client\Network Access Manager\system\configuration.xml"
$WinXPCheck = Test-Path $WinXpPath
$Win7Check = Test-Path $Win7Path
$ConfHashValue = '58B776D78C4CE8DCC1B59BA99EAA0D38'
if (!$Win7Check -and !$WinXPCheck) {
	exit
} elseif ($Win7Check) {
	if ((Get-FileHash -Path $Win7Path).HashValue -ne $ConfHashValue) {
		exit	
	}
} elseif ($WinXpCheck) {
	if ((Get-FileHash -Path $WinXpPath).HashValue -ne $ConfHashValue) {
		exit
	}
}

## Check if the other configuration file got copied properly
$InstallLocation = Get-InstallLocation -ProductName 'Cisco NAC Agent'
if (!(Test-Path "$InstallLocation\NACAgentCFG.xml")) {
	exit
}

## Check if the connection notices were disabled for the current user
## This isn't a thorough check because the installer disables for all users but it's close
New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
$LoggedOnSids = Get-LoggedOnUserSID
foreach ($sid in $LoggedOnSids) {
	try {
		$Popups = Get-ItemProperty -Path "HKU:\$sid\SOFTWARE\Cisco\Cisco AnyConnect Secure Mobility Client" -Name 'EnableStatusPopups'
		if ($Popups -and ($Popups.EnableStatusPopups -ne '0')) {
			exit
		}
	} catch {
		exit
	}
}
$true