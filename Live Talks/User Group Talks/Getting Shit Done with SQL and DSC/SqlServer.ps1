#requires -Version 5

Configuration SQLStandalone
{
    param(
        [pscredential]$SetupCredential ## Need to pass a credential for setup
    )
    ## Download the xSQLServer module from the PowerShell Gallery
    Import-DscResource -Module xSQLServer

    ## Run this DSC configuration on the localhost
    Node 'localhost'
    {
        ## Install a prerequsite Windows feature
        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = "\\MEMBERSRV1\Installers\WindowsServer2012R2\sources\sxs"
        }

        ## Have DSC grab install bits from the SourcePath, install under the instance name with the features
        ## using the specified SQL Sys admin accounts. Be sure to install the Windows feature first.
        xSqlServerSetup 'SqlServerSetup'
        {
            DependsOn = "[WindowsFeature]NET-Framework-Core"
            SourcePath = '\\MEMBERSRV1\Installers\SqlServer2016'
            SetupCredential = $SetupCredential
            InstanceName = 'MSSQLSERVER'
            Features = 'SQLENGINE,FULLTEXT,RS,AS,IS'
            SQLSysAdminAccounts = 'mylab.local\Administrator'
        }

        ## Add firewall exceptions for SQL Server but run SQL server setup first.
        xSqlServerFirewall 'SqlFirewall'
        {
            DependsOn = '[xSqlServerSetup]SqlServerSetup'
            SourcePath = '\\MEMBERSRV1\Installers\SqlServer2016'
            InstanceName = 'MSSQLSERVER'
            Features = 'SQLENGINE,FULLTEXT,RS,AS,IS'
        }
    }
}