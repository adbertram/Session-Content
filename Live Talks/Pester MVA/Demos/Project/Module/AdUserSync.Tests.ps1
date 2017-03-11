## TESTS FOR ALL FUNCTIONS REFERENCED IN THE SYNC-ADUSER.PS1 SCRIPT.

## Remove all loaded functions
Get-Module -Name AdUserSync -All | Remove-Module -Force

## Ensure functions are not called from modules that are already loaded
Import-Module "$PSScriptRoot\AdUserSync.psm1" -Force

InModuleScope 'AdUserSync' {
    describe 'Get-AdUserDefaultPassword' {

        ## Must mock this to control what gets passed to ConvertTo-SecureString and we're asserting this command was called.
        mock 'Import-CliXml' {
            $testCred = New-MockObject -Type 'System.Management.Automation.PSCredential'

            ## No built-in way to mock a .NET method. We must use PowerShell extended type system to replace it instead.
            $addMemberParams = @{
                MemberType = 'ScriptMethod'
                Name = 'GetNetworkCredential'
                Value = { @{'Password' = 'Foo'} }
                Force = $true
            }
            $testCred | Add-Member @addMemberParams
            $testCred
        }

        it 'builds the default FilePath parameter correctly and passes it to Import-CliXml' {

            ## Assign to $null. I'm just asserting a command was called. I don't care what it returns.
            $null = Get-AdUserDefaultPassword

            $assMParams = @{
                CommandName = 'Import-CliXMl'
                Times = 1
                Exactly = $true
                Scope = 'It'
                ParameterFilter = { 
                    $Path -eq 'C:\DropBox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos\Project\Artifacts\DefaultUserPassword.xml' 
                }
            }
            Assert-MockCalled @assMParams
        }

        it 'returns a single secure string' {
            
            $result = Get-AdUserDefaultPassword

            ## Figure out what type of object ConvertTo-SecureString returns to get this assertion
            ## ConvertTo-SecureString -String 'foo' -AsPlainText -Force | Get-Member

            $result.Count | should be 1
            $result | should beofType 'System.Security.SecureString'
        }

        it 'converts the expected password to a secure string' {

            ## This It block is last on purpose because I'm creating a mock that I don't want applied to the It
            ## blocks above.        

            mock 'ConvertTo-SecureString'

            $null = Get-AdUserDefaultPassword

            $assMParams = @{
                CommandName = 'ConvertTo-SecureString'
                Times = 1
                Exactly = $true
                Scope = 'It'
                ParameterFilter = { $String -eq 'Foo' } ## Output from our "mocked" GetNetworkCredential method
            }
            Assert-MockCalled @assMParams

        }
    }

    describe 'Get-ActiveEmployee' {

        ## "Fake"" CSV data just to test with based on the real data
        mock 'Import-Csv' {
            ConvertFrom-Csv -InputObject @'
    "FirstName","LastName","Department","Title"
    "Katie","Green","Accounting","Manager of Accounting"
    "Joe","Blow", "Information Systems","System Administrator"
    "Joe","Schmoe", "Information Systems", "Software Developer"
    "Barack","Obama", "Executive Office", "CEO"
    "Donald","Trump", "Janitorial Services", "Custodian"
'@
        }

        mock 'Test-Path' {
            $true
        }

        it 'returns the expected number of objects' {

            $result = Get-ActiveEmployee
            $result.Count | should be 5

        }

        it 'returns objects that have an ADuserName property appended' {
            
            ## I've chosen not to mock the function (Get-EmployeeUserName) creates the ADUserName property. I do this because
            ## I trust this function because I also have tests for it.

            $result = Get-ActiveEmployee
            $result.ADUserName | should not benullorempty

        }

        it 'returns objects that have an OUPath property appended' {
            
            $result = Get-ActiveEmployee
            $result.OUPath | should not benullorempty

        }

        it 'throws an exception when the CSV file cannot be found' {
            
            mock 'Test-Path' {
                $false
            }

            { Get-ActiveEmployee } | should throw 'could not be found'
        }


        it 'builds the default FilePath parameter correctly and passes it to Import-Csv' {

            mock 'Import-Csv'

            mock 'Test-Path' {
                $true
            }

            ## This it block is last again on purpose
            $null = Get-ActiveEmployee

            $assMParams = @{
                CommandName = 'Import-Csv'
                Times = 1
                Exactly = $true
                Scope = 'It'
                ParameterFilter = { 
                    $Path -eq 'C:\DropBox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos\Project\Artifacts\Employees.csv' 
                }
            }
            Assert-MockCalled @assMParams
        }
    }

    describe 'Get-InactiveEmployee' {

        mock 'Get-ActiveEmployee' {
            ## Must create something with ADUserName since we're referencing that property in the function.
            [pscustomobject]@{
                ADUserName = 'user1'
            }
            [pscustomobject]@{
                ADUserName = 'user2'
            }
            [pscustomobject]@{
                ADUserName = 'user3'
            }
        }

        it 'should only query for AD users that are enabled' {

            ## This will only create the mock if the parameter filter is $true
            mock 'Get-AdUser' {

            } -ParameterFilter { $Filter -like "*Enabled -eq 'True'*" }

            $null = Get-InactiveEmployee

            $assMParams = @{
                CommandName = 'Get-AdUser'
                Times = 1
                Exactly = $true
                Scope = 'It'
            }
            Assert-MockCalled @assMParams
        }

        it 'should exclude the domain administrator account from the AD user query' {

            ## This will only create the mock if the parameter filter is $true
            mock 'Get-AdUser' {

            } -ParameterFilter { $Filter -like "*SamAccountName -ne 'Administrator'*" }

            $null = Get-InactiveEmployee

            $assMParams = @{
                CommandName = 'Get-AdUser'
                Times = 1
                Exactly = $true
                Scope = 'It'
            }
            Assert-MockCalled @assMParams
        }

        it 'should only return AD users that are not in the CSV file' {

            ## Purposefully add users that are AND aren't active to test the filter
            mock 'Get-AdUser' {
                [pscustomobject]@{
                    samAccountName = 'user1'
                }
                [pscustomobject]@{
                    samAccountName = 'user2'
                }
                [pscustomobject]@{
                    samAccountName = 'inactive1'
                }
                [pscustomobject]@{
                    samAccountName = 'inactive2'
                }
            } -ParameterFilter { $Filter } ## This is required since we're mocking with the param filter above

            $result = Get-InactiveEmployee
            
            diff $result.samAccountName @('inactive1','inactive2') | should benullorempty

        }   
    }

    describe 'Get-EmployeeUsername' {

        $result = Get-EmployeeUsername -FirstName 'Bob' -LastName 'Jones'

        it 'should return a single string' {
            @($result).Count | should be 1
            $result | should beofType 'string'
        }
        
        ## This test is technically not required since we're inherently testing this in the assertion below. However,
        ## I choose to do this to make the tests more explicit and easier to pinpoint problems.
        it 'should return the first initial of the first name as the first character' {
            $result.SubString(0,1) | should be 'B'
        }

        it 'should return the expected username' {
            $result | should be 'BJones'
        }
    }

    describe 'Get-DepartmentOUPath' {
    $result = Get-DepartmentOUPath -OUPath 'departmentHere'

    it 'returns a single string' {
            @($result).Count | should be 1
            $result | should beofType 'string'
    } 

    it 'returns the expected OU path' {
            $result | should be 'OU=departmentHere,DC=mylab,DC=local'
    }
    }

    describe 'Test-AdUserExists' {
        
        it 'returns $true if the user account can be found in AD' {
            mock 'Get-AdUser' {
                $true
            }
            $result = Test-AdUserExists -UserName 'bjones'
            $result | should be $true
        }

        it 'returns $false if the user account cannot be found in AD' {
            mock 'Get-AdUser'

            $result = Test-AdUserExists -UserName 'bjones'
            $result | should be $false
        }
    }

    describe 'Test-AdGroupExists' {


        it 'returns $true if the group can be found in AD' {
            mock 'Get-AdGroup' {
                $true
            }
            $result = Test-AdGroupExists -Name 'whatever'
            
            $result | should be $true
        }

        it 'returns $false if the group cannot be found in AD' {
            mock 'Get-AdGroup'

            $result = Test-AdGroupExists -Name 'whatever'
            $result | should be $false
        }
    }

    describe 'Test-AdGroupMemberExists' {

        it 'returns $true if the username is a member of the group' {
            mock 'Get-AdGroupMember' {
                @{
                    Name = 'bjones'
                }
            }

            $result = Test-AdGroupMemberExists -UserName 'bjones' -GroupName 'groupnamehere'
                
            $result | should be $true
        }

        it 'returns $false if the username is not a member of the group' {
            mock 'Get-AdGroupMember' {
                @{
                    Name = 'someotherusernamehere'
                }
            }

            $result = Test-AdGroupMemberExists -UserName 'bjones' -GroupName 'groupnamehere'
            
            $result | should be $false
        }
    }

    describe 'Test-ADOrganizationalUnitExists' {
        
        it 'creates the proper full OU DN and passes to Get-ADOrganizationalUnit' {
            mock 'Get-ADOrganizationalUnit' {
                $true
            }

            $null = Test-ADOrganizationalUnitExists -DistinguishedName 'OU=departmentHere,DC=mylab,DC=local'

            $assMParams = @{
                CommandName = 'Get-AdOrganizationalUnit'
                Times = 1
                Exactly = $true
                Scope = 'It'
                ParameterFilter = {$Filter -eq "DistinguishedName -eq 'OU=departmentHere,DC=mylab,DC=local'" }
            }
            Assert-MockCalled @assMParams
        }

        it 'returns $true if the group can be found in AD' {

            $result = Test-ADOrganizationalUnitExists -DistinguishedName 'OU=departmentHere,DC=mylab,DC=local'
            $result | should be $true
        }

        it 'returns $false if the group cannot be found in AD' {
            mock 'Get-ADOrganizationalUnit'

            $result = Test-ADOrganizationalUnitExists -DistinguishedName 'OU=departmentHere,DC=mylab,DC=local'
            
            $result | should be $false
        }
    }

    describe 'New-CompanyAdUser' {

        function DecryptSecureString {
            param($String)
            [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($String))
        }

        $securePass = (ConvertTo-SecureString -String 'foo' -AsPlainText -Force)
        $ptPass = DecryptSecureString -String $securePass

        mock 'Get-ADUserDefaultPassword' {
            $securePass
        }

        mock 'New-AdUser'

        mock 'New-Aduser' {

        } -ParameterFilter {
            $UserPrincipalName -eq 'fLastNameHere' -and
            $Name -eq 'fLastNameHere' -and
            $GivenName -eq 'firstNameHere' -and
            $SurName -eq 'lastNameHere' -and
            $Title -eq 'titleHere' -and
            $Department -eq 'departmentHere' -and
            $SamAccountName -eq 'fLastNameHere' -and
            (DecryptSecureString $AccountPassword) -eq $ptPass -and
            $Path -eq 'OU=Users,DC=mylab,DC=local' -and
            $Enabled -eq $true -and
            $ChangePasswordAtLogon -eq $true
        } -Verifiable

        $params = @{
            Employee = [pscustomobject]@{
                FirstName = 'firstNameHere'
                LastName = 'lastNamehere'
                Department = 'departmenthere'
                Title = 'titleHere'
            }
            Username = 'flastNameHere'
            OrganizationalUnit = 'OU=Users,DC=mylab,DC=local'
        }
        $result = New-CompanyAdUser @params

        it 'should attempt to create an AD user with the proper parameters' {

            Assert-VerifiableMocks
        }
    }
}