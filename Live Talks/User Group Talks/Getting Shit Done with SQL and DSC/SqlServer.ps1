#requires -Version 5

Configuration SQLStandalone
{
    param(
        [pscredential]$SetupCredential
    )
    Import-DscResource -Module xSQLServer

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = "$($ConfigurationData.NonNodeData.Roles.SqlServer.SourcePath)\WindowsServer2012R2\sources\sxs"
        }
        
        if ($Node.Role -eq 'SQLServer') {
            xSqlServerSetup 'SqlServerSetup'
            {
                DependsOn = "[WindowsFeature]NET-Framework-Core"
                SourcePath = "$($ConfigurationData.NonNodeData.Roles.SqlServer.SourcePath)\SqlServer2016"
                SetupCredential = $SetupCredential
                InstanceName = $ConfigurationData.NonNodeData.Roles.SqlServer.InstanceName
                Features = $ConfigurationData.NonNodeData.Roles.SqlServer.Features
                SQLSysAdminAccounts = $ConfigurationData.NonNodeData.Roles.SqlServer.AdminAccount
                InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
                InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
                InstanceDir = "C:\Program Files\Microsoft SQL Server"
                InstallSQLDataDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                SQLUserDBDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                SQLUserDBLogDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                SQLTempDBDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                SQLTempDBLogDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                SQLBackupDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                ASDataDir = "C:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Data"
                ASLogDir = "C:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Log"
                ASBackupDir = "C:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Backup"
                ASTempDir = "C:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Temp"
                ASConfigDir = "C:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config"
            }

            xSqlServerFirewall 'SqlFirewall'
            {
                DependsOn = '[xSqlServerSetup]SqlServerSetup'
                SourcePath = "$($ConfigurationData.NonNodeData.Roles.SqlServer.SourcePath)\SqlServer2016"
                InstanceName = $ConfigurationData.NonNodeData.Roles.SqlServer.InstanceName
                Features = $ConfigurationData.NonNodeData.Roles.SqlServer.Features
            }
        }
    }
}

$InstallerServiceAccount = Get-Credential -UserName 'mylab.local\administrator' -Message 'Input credentials for installing SQL Server'
#$LocalSystemAccount = Get-Credential "SYSTEM"

SQLStandalone -ConfigurationData "$PSScriptRoot\ConfigurationData.psd1" -SetupCredential $InstallerServiceAccount
Set-DscLocalConfigurationManager -Path .\SQLStandalone -Verbose
Start-DscConfiguration -Path .\SQLStandalone -Verbose -Wait -Force