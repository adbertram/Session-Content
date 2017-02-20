configuration NewTestEnvironment
{        
    Import-DscResource -ModuleName xActiveDirectory             
            
    Node @($AllNodes).where({ $_.Purpose -eq 'Domain Controller' }).Nodename             
    {             
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }

        @($ConfigurationData.NonNodeData.ADGroups).foreach({
            xADGroup $_
            {
                Ensure = 'Present'
                GroupName = $_
                DependsOn = '[xADDomain]ADDomain'
            }
        })

        @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach({
            xADOrganizationalUnit $_
            {
                Ensure = 'Present'
                Name = ($_ -replace '-')
                Path = 'DC=mylab,DC=local'
                DependsOn = '[xADDomain]ADDomain'
            }
        })

        $pw = ConvertTo-SecureString 'P@$$w0rd19' -AsPlainText -Force
        $defaultUserCred = New-Object System.Management.Automation.PSCredential ('administrator',$pw)
        @($ConfigurationData.NonNodeData.ADUsers).foreach({
            xADUser "$($_.FirstName) $($_.LastName)"
            {
                Ensure = 'Present'
                DomainName = $ConfigurationData.NonNodeData.DomainName
                GivenName = $_.FirstName
                SurName = $_.LastName
                UserName = ('{0}{1}' -f $_.FirstName.SubString(0,1),$_.LastName)
                Department = $_.Department
                Path = "OU=$($_.Department),DC=mylab,DC=local"
                JobTitle = $_.Title
                Password = $defaultUserCred
                DependsOn = '[xADDomain]ADDomain'
            }
        })

        ($Node.WindowsFeatures).foreach({
            WindowsFeature $_
            {
                Ensure = 'Present'
                Name = $_
            }
        })        
        
        $pw = ConvertTo-SecureString 'p@$$w0rd19' -AsPlainText -Force
        $domainCred = New-Object System.Management.Automation.PSCredential ('administrator',$pw)
        xADDomain ADDomain          
        {             
            DomainName = $ConfigurationData.NonNodeData.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $domainCred
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }         
} 

NewTestEnvironment -ConfigurationData "$PSScriptRoot\ConfigurationData.psd1"
Set-DSCLocalConfigurationManager -Path .\NewTestEnvironment -Force -ComputerName DC2 -Verbose
Start-DscConfiguration -Wait -Force -Path .\NewTestEnvironment -ComputerName DC2 -Verbose