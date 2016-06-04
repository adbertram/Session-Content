function New-EmployeeOnboardUser
{
	<#
	.SYNOPSIS
		This function automates a lot of the common tasks that must happen when a new employee is hired. It defaults to all of the company standards but allows for ad-hoc changing if necessary. It will create the AD user account, add the account to the appropriate groups and place the account into the appropriate OU.
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
    .PARAMETER BaseHomeFolderPath
        This is a UNC path that designates where to create the user's home folder.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipelineByPropertyname)]
		[ValidateNotNullOrEmpty()]
		[string]$FirstName,
		
		[Parameter(Mandatory, ValueFromPipelineByPropertyname)]
		[ValidateNotNullOrEmpty()]
		[string]$LastName,
		
		[Parameter(ValueFromPipelineByPropertyname)]
		[string]$MiddleInitial,
		
		[Parameter(ValueFromPipelineByPropertyname)]
		[ValidateNotNullOrEmpty()]
		[string]$Location = 'OU=Corporate Users',
		
		[Parameter(ValueFromPipelineByPropertyname)]
		[string]$Department,
		
		[Parameter(ValueFromPipelineByPropertyname)]
		[string]$Title,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$DefaultGroup = 'All Users',
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$DefaultPassword = 'p@$$w0rd12345',
		
		## Don't do this...really

		
		[Parameter()]
		[ValidateScript({ Test-Path -Path $_ })]
		[string]$BaseHomeFolderPath = '\\MEMBERSRV1\Users',
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[pscredential]$Credential
		
	)
	process
	{
		try
		{
			$commonAdParams = @{ }
			if ($PSBoundParameters.ContainsKey('Credential'))
			{
				$commonAdParams.Credential = $Credential
			}
			
			## Find the distinguished name of the domain the current computer is a part of.
			$DomainDn = (Get-AdDomain @commonAdParams).DistinguishedName
			
			## Define the 'standard' username (first initial and last name)
			$Username = "$($FirstName.SubString(0, 1))$LastName"
			
			#region Check if an existing user already has the first intial/last name username taken
			Write-Verbose -Message "Checking if [$($Username)] is available"
			if (Get-ADUser @commonAdParams -Filter "Name -eq '$Username'")
			{
				Write-Warning -Message "The username [$($Username)] is not available."
				
				if (-not $PSBoundParameters.ContainsKey('MiddleInitial'))
				{
					throw "Could not check alternate username. Middle initial was not provided."
				}
				else
				{
					
					## If so, check to see if the first initial/middle initial/last name is taken.
					$Username = "$($FirstName.SubString(0, 1))$MiddleInitial$LastName"
					Write-Verbose -Message "Checking alternative username [$($Username)]..."
					
					if (Get-ADUser @commonAdParams -Filter "Name -eq '$Username'")
					{
						throw "No acceptable username schema could be created"
					}
					else
					{
						Write-Verbose -Message "The alternate username [$($Username)] is available."
					}
					
				}
			}
			else
			{
				Write-Verbose -Message "The username [$($Username)] is available"
			}
			#endregion
			
			#region Ensure the OU the user's going into exists
			$ouDN = "$Location,$DomainDn"
			if (-not (Get-ADOrganizationalUnit @commonAdParams -Filter "DistinguishedName -eq '$ouDN'"))
			{
				throw "The user OU [$($ouDN)] does not exist. Can't add a user there"
			}
			#endregion
			
			#region Ensure the groups the user's going into exists
			
			$groups = @($DefaultGroup)
			if ($Department)
			{
				$groups += $Department
			}
			
			$groups.foreach({
				if (-not (Get-ADGroup @commonAdParams -Filter "Name -eq '$_'"))
				{
					throw "The group [$($_)] does not exist. Can't add the user into this group."
				}
			})
			
			#endregion
			
			#region Ensure the home folder to create doesn't already exist
			$homeFolderPath = "$BaseHomeFolderPath\$UserName"
			
			if (Test-Path -Path $homeFolderPath)
			{
				throw "The home folder path [$homeFolderPath] already exists."
			}
			#endregion
			
			#region Create the new user
			$NewUserParams = $commonAdParams + @{
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
			
			#region Add user to groups
			$groups.foreach({
				Write-Verbose -Message "Adding the user account [$($Username)] to the group [$($_)]"
				Add-ADGroupMember @commonAdParams -Members $Username -Identity $_
			})
			
			#endregion
			
			#region Create the home folder
			
			Write-Verbose -message "Creating the home folder [$homeFolderPath]..."
			$null = mkdir $homeFolderPath
			
			#endregion
		}
		catch
		{
			Write-Error $_.Exception.Message
		}
	}
}