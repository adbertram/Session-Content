## Dot source the file that contains all of the functions. This will bring it into current scope
$parentFolder = $PSScriptRoot | Split-Path -Parent
$sut = "$($MyInvocation.MyCommand -replace '\.Tests\.ps1$', '').ps1"
. "$parentFolder\$sut"

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
                $Path -eq 'C:\DropBox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos\Artifacts\DefaultUserPassword.xml' 
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
                $Path -eq 'C:\DropBox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos\Artifacts\Employees.csv' 
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

}

describe 'Test-AdUserExists' {

}

describe 'Test-AdGroupExists' {

}

describe 'Test-AdGroupMemberExists' {

}

describe 'Test-ADOrganizationalUnitExists' {

}

describe 'New-CompanyAdUser' {

}