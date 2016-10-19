@{
	AllNodes = @(
		@{
			NodeName = '*'
			PsDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
		},
		@{
			NodeName = 'SQLSRV.mylab.local'
			Role = 'SQLServer'
		}
	)
	NonNodeData = @{
		Roles = @{
			SqlServer = @{
                InstanceName = 'MSSQLSERVER'
                Features = 'SQLENGINE,FULLTEXT,RS,AS,IS'
                SourcePath = "\\MEMBERSRV1\Installers"
                AdminAccount = "mylab.local\Administrator"
			}
		}
	}
}




















