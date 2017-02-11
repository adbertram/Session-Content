configuration NewTestDomain
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

        @($Node.ADGroups).foreach({
            xADGroup $_
            {
                Ensure = 'Present'
                GroupName = $_
                DependsOn = '[xADDomain]DcPromo'
            }
        })

        $pw = ConvertTo-SecureString 'P@$$w0rd19' -AsPlainText -Force
        $defaultUserCred = New-Object System.Management.Automation.PSCredential ('administrator',$pw)
        @($Node.ADUsers).foreach({
            xADUser "$($_.FirstName) $($_.LastName)"
            {
                Ensure = 'Present'
                DomainName = $ConfigurationData.NonNodeData.DomainName
                GivenName = $_.FirstName
                SurName = $_.LastName
                UserName = ('{0}{1}' -f $_.FirstName.SubString(0,1),$_.LastName)
                Department = $_.Department
                JobTitle = $_.Title
                Password = $defaultUserCred
                DependsOn = '[xADDomain]DcPromo'
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
        xADDomain DcPromo            
        {             
            DomainName = $ConfigurationData.NonNodeData.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $domainCred
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }   
    }         
} 

NewTestDomain -ConfigurationData "$PSScriptRoot\ConfigurationData.psd1"
Set-DSCLocalConfigurationManager -Path .\NewTestDomain -Verbose
Start-DscConfiguration -Wait -Force -Path .\NewTestDomain -Verbose