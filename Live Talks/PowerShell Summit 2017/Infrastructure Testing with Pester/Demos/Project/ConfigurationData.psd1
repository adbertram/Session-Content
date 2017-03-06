@{
	AllNodes = @(
		@{
			NodeName = '*'
			PsDscAllowDomainUser = $true
            PsDscAllowPlainTextPassword = $true
		},
		@{
			NodeName = 'DC2'
            Purpose = 'Domain Controller'
            WindowsFeatures = 'AD-Domain-Services'
        }
    )
    NonNodeData = @{
        DomainName = 'mytestlab.local'
        SafeModeAdministratorPassword = 'p@$$w0rd12'
        AdGroups = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        OrganizationalUnits = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        AdUsers = @(
            @{
                FirstName = 'Katie'
                LastName = 'Green'
                Department = 'Accounting'
                Title = 'Manager of Accounting'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Blow'
                Department = 'Information Systems'
                Title = 'System Administrator'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Schmoe'
                Department = 'Information Systems'
                Title = 'Software Developer'
            }
            @{
                FirstName = 'Barack'
                LastName = 'Obama'
                Department = 'Executive Office'
                Title = 'CEO'
            }
            @{
                FirstName = 'Donald'
                LastName = 'Trump'
                Department = 'Janitorial Services'
                Title = 'Custodian'
            }
        )
    }
}