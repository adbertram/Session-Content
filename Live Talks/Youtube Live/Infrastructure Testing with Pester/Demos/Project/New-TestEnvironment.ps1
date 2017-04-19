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

        @($ConfigurationData.NonNodeData.ADGroups).foreach( {
                xADGroup $_
                {
                    Ensure = 'Present'
                    GroupName = $_
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

        @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach( {
                xADOrganizationalUnit $_
                {
                    Ensure = 'Present'
                    Name = ($_ -replace '-')
                    Path = ('DC={0},DC={1}' -f ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

        $pw = ConvertTo-SecureString 'DoNotDoThis.' -AsPlainText -Force
        $defaultUserCred = New-Object System.Management.Automation.PSCredential ('administrator', $pw)
        @($ConfigurationData.NonNodeData.ADUsers).foreach( {
                xADUser "$($_.FirstName) $($_.LastName)"
                {
                    Ensure = 'Present'
                    DomainName = $ConfigurationData.NonNodeData.DomainName
                    GivenName = $_.FirstName
                    SurName = $_.LastName
                    UserName = ('{0}{1}' -f $_.FirstName.SubString(0, 1), $_.LastName)
                    Department = $_.Department
                    Path = ("OU={0},DC={1},DC={2}" -f $_.Department, ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    JobTitle = $_.Title
                    Password = $defaultUserCred
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

        ($Node.WindowsFeatures).foreach( {
                WindowsFeature $_
                {
                    Ensure = 'Present'
                    Name = $_
                }
            })        
        
        $pw = ConvertTo-SecureString 'DoNotDoThis.' -AsPlainText -Force
        $domainCred = New-Object System.Management.Automation.PSCredential ('administrator', $pw)
        xADDomain ADDomain          
        {             
            DomainName = $ConfigurationData.NonNodeData.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $domainCred
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }         
} 

## Download the AD DSC modules
#SInvoke-Command -ComputerName TESTLABDC -ScriptBlock { Install-Module -Name xActiveDirectory -Force }

Set-Location 'C:\Dropbox\GitRepos\Session-Content\Live Talks\Youtube Live\Infrastructure Testing with Pester\Demos\Project'
$null = NewTestEnvironment -ConfigurationData "$PSScriptRoot\ConfigurationData.psd1" -WarningAction SilentlyContinue -Verbose
Set-DSCLocalConfigurationManager -Path .\NewTestEnvironment -ComputerName TESTLABDC -Verbose -Force
Start-DscConfiguration -Wait -Force -Path .\NewTestEnvironment -ComputerName TESTLABDC -Verbose