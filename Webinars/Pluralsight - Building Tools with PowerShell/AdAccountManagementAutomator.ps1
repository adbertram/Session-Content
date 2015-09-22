function New-EmployeeOnboardUser {
	<#
	.SYNOPSIS
		This function is part of the Active Directory Account Management Automator tool.  It is used to perform all routine
		tasks that must be done when onboarding a new employee user account.
	.EXAMPLE
		PS> New-EmployeeOnboardUser -FirstName 'adam' -MiddleInitial D -LastName Bertram -Title 'Dr. Awesome'
	
		This example creates an AD username based on company standards into a company-standard OU and adds the user
		into the company-standard main user group.
	.PARAMETER FirstName
	 	The first name of the employee
	.PARAMETER LastName
		The last name of the employee
	.PARAMETER MiddleInitial
		The middle initial of the employee
	.PARAMETER Location
		The organizational unit in distinguished name syntax where the user account will be created.
	.PARAMETER Department
        The internal department this employee is in.
    .PARAMETER Title
		The current job title of the employee
	.PARAMETER DefaultGroup
		The name of the group that the user account will become a member of.
	.PARAMETER DefaultPassword
		The password that will be applied to the user account.  This is forced to change immediately
		at logon.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$FirstName,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$LastName,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$MiddleInitial,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Location = 'OU=Corporate Users',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Department,
	
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Title,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$DefaultGroup = 'Gigantic Corporation Inter-Intra Synergy Group',
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$DefaultPassword = 'p@$$w0rd12345' ## Don't do this...really
	
	)	
	try
	{
		$DomainDn = (Get-AdDomain).DistinguishedName
		
		$Username = "$($FirstName.SubString(0, 1))$LastName"
		
		#region Check if an existing user already has the first intial/last name username taken
		Write-Verbose -Message "Checking if [$($Username)] is available"
		if (Get-ADUser -Filter "Name -eq '$Username'")
		{
			Write-Warning -Message "The username [$($Username)] is not available. Checking alternate..."
			## If so, check to see if the first initial/middle initial/last name is taken.
			$Username = "$($FirstName.SubString(0, 1))$MiddleInitial$LastName"
			if (Get-ADUser -Filter "Name -eq '$Username'")
			{
				throw "No acceptable username schema could be created"
			}
			else
			{
				Write-Verbose -Message "The alternate username [$($Username)] is available."
			}
		}
		else
		{
			Write-Verbose -Message "The username [$($Username)] is available"
		}
		#endregion
		
		#region Ensure the OU the user's going into exists
		$ouDN = "$Location,$DomainDn"
		if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'"))
		{
			throw "The user OU [$($ouDN)] does not exist. Can't add a user there"	
		}
		#endregion
		
		#region Ensure the group the user's going into exists
		if (-not (Get-ADGroup -Filter "Name -eq '$DefaultGroup'"))
		{
			throw "The group [$($DefaultGroup)] does not exist. Can't add the user into this group."	
		}
		#endregion
		
		#region Create the new user
		$NewUserParams = @{
			'UserPrincipalName' = $Username
			'Name' = $Username
			'GivenName' = $FirstName
			'Surname' = $LastName
			'Title' = $Title
            'Department' = $Department
			'SamAccountName' = $Username
			'AccountPassword' = (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)
			'Enabled' = $true
			'Initials' = $MiddleInitial
			'Path' = "$Location,$DomainDn"
			'ChangePasswordAtLogon' = $true
		}
		Write-Verbose -Message "Creating the new user account [$($Username)] in OU [$($ouDN)]"
		New-AdUser @NewUserParams
		#endregion
		
		#region Add user to group
		Write-Verbose -Message "Adding the user account [$($Username)] to the group [$($DefaultGroup)]"
		Add-ADGroupMember -Members $Username -Identity $DefaultGroup
		#endregion
	}
	catch
	{
		Write-Error $_.Exception.Message
	}
}

function New-EmployeeOnboardComputer {
	<#
	.SYNOPSIS
		This function is part of the Active Directory Account Management Automator tool.  It is used to perform all routine
		tasks that must be done when onboarding a new AD computer account.
	.EXAMPLE
		PS> New-EmployeeOnboardComputer -FirstName 'adam' -MiddleInitial D -LastName Bertram -Title 'Dr. Awesome'
	
		This example creates an AD username based on company standards into a company-standard OU and adds the user
		into the company-standard main user group.
	.PARAMETER Computername
	 	The name of the computer to create in AD
	.PARAMETER Location
		The AD distinguishedname of the OU that the computer account will be created in
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$ComputerName,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Location = 'OU=Corporate Computers'
		
	)
	begin
	{
		$DomainDn = (Get-AdDomain).DistinguishedName	
	}
	process {
		try
		{
			#region Ensure the OU exists
			$ouDN = "$Location,$DomainDn"
			if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'"))
			{
				throw "The computer OU [$($ouDN)] does not exist. Can't add a computer there"
			}
			#endregion
			
			#region Check to see if the computer account already exists
			Write-Verbose -Message "Checking to see if the computer [$($ComputerName)] already exists."
			if (Get-AdComputer -Filter "Name -eq '$ComputerName'")
			{
				throw "The computer name '$ComputerName' already exists"
			}
			else
			{
				Write-Verbose -Message "The computer [$($ComputerName)] is available"
			}
			#endregion
			
			Write-Verbose -Message "Creating the computer [$($ComputerName)] in the OU [$($ouDn)]"
			New-ADComputer -Name $ComputerName -Path $ouDN
		}
		catch 
		{
			Write-Error $_.Exception.Message
		}
	}
}