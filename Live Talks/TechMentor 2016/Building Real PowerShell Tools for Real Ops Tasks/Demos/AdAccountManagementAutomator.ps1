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
	.PARAMETER MiddleInitial
		The middle initial of the employee
	.PARAMETER LastName
		The last name of the employee
	.PARAMETER Title
		The current job title of the employee
	#>
	[CmdletBinding()]
	param (
		[string]$Firstname,
		[string]$MiddleInitial,
		[string]$LastName,
		[string]$Location = 'OU=Corporate Users',
		[string]$Title
	)
	process {
		## Not the best use of storing the password clear text
		## Google/Bing on using stored secure strings on the file system as a way to get around this
		$DefaultPassword = 'p@$$w0rd12'
		$DomainDn = (Get-AdDomain).DistinguishedName
		$DefaultGroup = 'Gigantic Corporation Inter-Intra Synergy Group'
			
		$Username = "$($FirstName.SubString(0, 1))$LastName"
		## Check if an existing user already has the first intial/last name username taken
		try {
            if (Get-ADUser $Username) {
				## If so, check to see if the first initial/middle initial/last name is taken.
				$Username = "$($FirstName.SubString(0, 1))$MiddleInitial$LastName"
				if (Get-AdUser $Username) {
					throw "No acceptable username schema could be created"
				}
			}
		} catch {
            Write-Error $_.Exception.Message
        }
		$NewUserParams = @{
            'UserPrincipalName' = $Username
            'Name' = $Username
            'GivenName' = $FirstName
            'Surname' = $LastName
            'Title' = $Title
            'SamAccountName' = $Username
            'AccountPassword' = (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)
            'Enabled' = $true
            'Initials' = $MiddleInitial
            'Path' = "$Location,$DomainDn"
            'ChangePasswordAtLogon' = $true
        }
			
		New-AdUser @NewUserParams
		Add-ADGroupMember $Username $DefaultGroup
        $Username
	}
}

function Set-MyAdUser {
	<#
	.SYNOPSIS
		This function is part of the Active Directory Account Management Automator tool.  It is used to modify
		one or more Active Directory attributes on a single Active Directory user account.
	.EXAMPLE
		PS> Set-MyAdUser -Username adam -Attributes @{'givenName' = 'bob'; 'DisplayName' = 'bobby bertram'; 'Title' = 'manager'}
	
		This example changes the givenName to bob, the display name to 'bobby bertram' and the title to 'manager' for the username 'adam'
	.PARAMETER Username
	 	An Active Directory username to modify
	.PARAMETER Attributes
		A hashtable with keys as Set-AdUser parameter values and values as Set-AdUser parameter argument values
	#>
	[CmdletBinding()]
	param (
		[string]$Username,
		[hashtable]$Attributes
	)
	process {
		try {
			## Attempt to find the username
			$UserAccount = Get-AdUser -Identity $Username
			if (!$UserAccount) {
				## If the username isn't found throw an error and exit
				#Write-Error "The username '$Username' does not exist"
				throw "The username '$Username' does not exist"
			}
			
			## The $Attributes parameter will contain only the parameters for the Set-AdUser cmdlet other than
			## Password.  If this is in $Attributes it needs to be treated differently.
			if ($Attributes.ContainsKey('Password')) {
				$UserAccount | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Attributes.Password -Force)
				## Remove the password key because we'll be passing this hashtable directly to Set-AdUser later
				$Attributes.Remove('Password')
			}
			
			$UserAccount | Set-AdUser @Attributes
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}

function Set-MyAdComputer {
	<#
	.SYNOPSIS
		This function is part of the Active Directory Account Management Automator tool.  It is used to modify
		one or more Active Directory attributes on a single Active Directory computer account.
	.EXAMPLE
		PS> Set-MyAdComputer -Computername adampc -Attributes @{'Location' = 'Phoenix'; 'Description' = 'is a little problematic'}
	
		This example changes the location to Phoenix and the description of the AD computer adampc to 'is a little problematic'
	.PARAMETER Computername
	 	An Active Directory computer account to modify
	.PARAMETER Attributes
		A hashtable with keys as Set-AdComputer parameter values and values as Set-AdComputer parameter argument values
	#>
	[CmdletBinding()]
	param (
		[string]$Computername,
		[hashtable]$Attributes
	)
	process {
		try {
			## Attempt to find the Computername
			$Computer = Get-AdComputer -Identity $Computername
			if (!$Computer) {
				## If the Computername isn't found throw an error and exit
				#Write-Error "The Computername '$Computername' does not exist"
				throw "The Computername '$Computername' does not exist"
			}
			
			## The $Attributes parameter will contain only the parameters for the Set-AdComputer cmdlet
			$Computer | Set-AdComputer @Attributes
		} catch {
			Write-Error $_.Exception.Message
		}
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
		[string]$Computername,
		[string]$Location
	)
	process {
		try {
			if (Get-AdComputer $Computername) {
				#Write-Error "The computer name '$Computername' already exists"
				throw "The computer name '$Computername' already exists"
			}
			
			$DomainDn = (Get-AdDomain).DistinguishedName
			$DefaultOuPath = "$Location,$DomainDn"
			
			New-ADComputer -Name $Computername -Path $DefaultOuPath
		} catch {
			Write-Error $_.Exception.Message
		}
	}
}