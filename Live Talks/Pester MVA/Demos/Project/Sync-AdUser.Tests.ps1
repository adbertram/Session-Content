## TESTS FOR THE SYNC-ADUSER.PS1 SCRIPT. ALL FUNCTIONS WITHIN THIS SCRIPT ALL Have
## TESTS FOR EACH OF THEM IN THE ADUSERSYNC MODULE TESTS.

############
# ARRANGE
############

## Pre-populate the dummy CSV file contents we'll be testing with for both active and inactive employees
## It's up here because this data is read in multiple tests.
$getActiveEmployeeOutput = ConvertFrom-Csv -InputObject @'
"FirstName","LastName","Department","Title","ADUserName","OUPath"
"Katie","Green","Accounting","Manager of Accounting","kgreen","OU=Accounting,DC=mylab,DC=local"
"Joe","Blow","Information Systems","System Administrator","jblow","OU=Information Systems,DC=mylab,DC=local"
"Joe","Schmoe","Information Systems", "Software Developer","jschmoe","OU=Information Systems,DC=mylab,DC=local"
"Barack","Obama","Executive Office", "CEO","bobama","OU=Executive Office,DC=mylab,DC=local"
"Donald","Trump","Janitorial Services", "Custodian","dtrump","OU=Janitorial Services,DC=mylab,DC=local"
'@

$getInActiveEmployeeOutput = ConvertFrom-Csv -InputObject @'
"FirstName","LastName","Department","Title","ADUserName","OUPath"
"Katie","Green","Accounting","Manager of Accounting","kgreen","OU=Accounting,DC=mylab,DC=local"
'@

## Import the module explicitly in case it's not imported already
Import-Module "$PSScriptRoot\Module\AdUserSync.psm1" -Force

## Figure out how to get the script to execute. This could be hardcoded but by doing this we can 
## resuse this technique in other test scripts.
$scriptFilePath = $MyInvocation.MyCommand.Path -replace '\.Tests\.ps1','.ps1' | Split-Path -Leaf
$scriptFilePath = "$PSScriptRoot\$scriptFilePath"

#region Start Tests

describe 'Sync-AdUser - missing CSV file' {

    ## Just need a single mock here because the script will exit quickly
    mock 'Get-ActiveEmployee' {
        throw 'could not be found'
    }

    it 'should throw an exception when the CSV file cannot be found' {
        { & $scriptFilePath } | should throw 'could not be found'
    }
}

describe 'Sync-AdUser - bad CSV data' {

    ## Just need a single mock here because the script will exit quickly
    mock 'Get-ActiveEmployee'
    
    it 'should throw an exception when there are no rows in the CSV file' {
        { & $scriptFilePath } | should throw 'No employees found in CSV file'
    }

}

describe 'Sync-AdUser - existing user tests' {

    ## Have Get-ActiveEmployee send fake data so we can easily control it
    mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    mock 'Test-ADUserExists' {
        $true
    }

    ## Mocking Write-Warning here just because we need to assert it
    mock 'Write-Warning'

    ## This has to be mocked because I don't want the script to do anything else after the user test.
    mock 'Get-InactiveEmployee'

    ## No need to see the output here since we're just asserting a command is called.
    $null = & $scriptFilePath

    it 'when a user already exists, it should write a warning to the console' {
        $assMParams = @{
            CommandName = 'Write-Warning'
            Times = 5 ## once for each user
            Exactly = $true
            ParameterFilter = {$Message -match 'Cannot create account' }
        }
        Assert-MockCalled @assMParams
    }

}

describe 'Sync-AdUser - OU tests' {

    ## Have Get-ActiveEmployee send fake data so we can easily control it
    mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    ## This must be here to get past this call in the function. We're not testing users right now.
    mock 'Test-ADUserExists' {
        $false
    }

    mock 'Test-ADOrganizationalUnitExists' {
        $false
    }

    mock 'Get-InactiveEmployee'

    it 'when an OU does not exist, it should throw an exception' {

        ## No assertion for throw here. Since we're catching the exceptions in the foreach loop and returning a non-terminating error
        $null = & $scriptFilePath -ErrorAction SilentlyContinue -ErrorVariable err
        $err | should belike 'Unable to find the OU*'
    }

}

describe 'Sync-AdUser - group tests' {

    mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    mock 'Test-ADUserExists' {
        $false
    }

    mock 'Test-ADOrganizationalUnitExists' {
        $true
    }

    mock 'New-CompanyAdUser'

    mock 'Get-AdUserDefaultPassword' {
       (ConvertTo-SecureString -String 'foo' -AsPlainText -Force)
   }

    mock 'Test-AdGroupExists' {
        $false
    }

    mock 'Get-InactiveEmployee'

    it 'when a group does not exist, it should throw an exception' {
        
        ## No assertion for throw here. Since we're catching the exceptions in the foreach loop and returning a non-terminating error
        $null = & $scriptFilePath -ErrorAction SilentlyContinue -ErrorVariable err
        $err | should belike 'Unable to find the group*'
    }

}

describe 'Sync-AdUser - user account creation' {

    mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    ## We're ensuring all of the validation passes so the script will get down to New-CompanyAdUser
    mock 'Test-ADUserExists' {
        $false
    }

    mock 'Test-ADOrganizationalUnitExists' {
        $true
    }

    mock 'Add-ADGroupMember'

    mock 'Test-AdGroupMemberExists' {
        $true
    }

    mock 'New-CompanyAdUser'

    mock 'Get-AdUserDefaultPassword' {
        (ConvertTo-SecureString -String 'foo' -AsPlainText -Force)
    }

    mock 'Test-AdGroupExists' {
        $true
    }

    mock 'Get-InactiveEmployee'

    ## not worried about the output again. Just execute the script. We'll check command assertions below.
    $null = & $scriptFilePath

    ## Run an assertion (It block) for every "fake" employee.
    ## I now can use the employee data in the It block names too.
    foreach ($emp in $getActiveEmployeeOutput) {

        it "[$($emp.OUPath)] should be the OrganizationalUnit parameter value passed to New-CompanyAdUser" {

            $assMParams = @{
                CommandName = 'New-CompanyAdUser'
                Times = 1
                Exactly = $true
                ParameterFilter = { $OrganizationalUnit -eq $emp.OUPath -and $UserName -eq $emp.ADUsername }
            }
            Assert-MockCalled @assMParams
        }

        it "[$($emp.FirstName)] should be the FirstName property on the Employee object parameter passed to New-CompanyAdUser" {

            $assMParams = @{
                CommandName = 'New-CompanyAdUser'
                Times = 1
                Exactly = $true
                ParameterFilter = {$Employee.FirstName -eq $emp.FirstName -and $UserName -eq $emp.ADUsername }
            }
            Assert-MockCalled @assMParams
        }

        it "[$($emp.LastName)] should be the LastName property on the Employee object parameter passed to New-CompanyAdUser" {

            $assMParams = @{
                CommandName = 'New-CompanyAdUser'
                Times = 1
                Exactly = $true
                ParameterFilter = {$Employee.LastName -eq $emp.LastName -and $UserName -eq $emp.ADUsername }
            }
            Assert-MockCalled @assMParams
        }

        it "[$($emp.Department)] should be the Department property on the Employee object parameter passed to New-CompanyAdUser" {

            $assMParams = @{
                CommandName = 'New-CompanyAdUser'
                Times = 1
                Exactly = $true
                ParameterFilter = {$Employee.Department -eq $emp.Department -and $UserName -eq $emp.ADUsername }
            }
            Assert-MockCalled @assMParams
        }

        it "[$($emp.Title)] should be the Title property on the Employee object parameter passed to New-CompanyAdUser" {

            $assMParams = @{
                CommandName = 'New-CompanyAdUser'
                Times = 1
                Exactly = $true
                ParameterFilter = {$Employee.Title -eq $emp.Title -and $UserName -eq $emp.ADUsername }
            }
            Assert-MockCalled @assMParams
        }
    }
}

describe 'Sync-AdUser - group member tests' {

    mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    mock 'Test-ADUserExists' {
        $false
    }

    mock 'Test-ADOrganizationalUnitExists' {
        $true
    }

    mock 'Test-AdGroupExists' {
        $true
    }

    ## This is what we're testing around now
    mock 'Add-ADGroupMember'

    ## Don't forget to mock functions that are in the parameters! Pester will still invoke these even if yu mock the 
    ## "parent" function
    mock 'Get-AdUserDefaultPassword' {
        (ConvertTo-SecureString -String 'foo' -AsPlainText -Force)
    }

    mock 'New-CompanyAdUser'

    mock 'Get-InactiveEmployee'
    
    ## This is less accurate but an example of what you can do if you just want to test total number of calls to a function.
    it 'when an account does not exist in the department group, it should add the account to that group' {
       
       mock 'Test-AdGroupMemberExists' {
            $false
        }

       ## We're putting the command call in each It block here because when mocking, the Assert-MockCalled function
       ## counts ALL instances in a describe block. If we put this in each It block and use the Scope It parameter
       ## we can count by It block.
        $null = & $scriptFilePath

        $assMParams = @{
            CommandName = 'Add-ADGroupMember'
            Times = 5
            Scope = 'It'
            Exactly = $true
        }
        Assert-MockCalled @assMParams
    }
        
    it 'when an account already exists in the group, it should skip it' {
        mock 'Test-AdGroupMemberExists' {
            $true
        }

        $null = & $scriptFilePath
        
        $assMParams = @{
            CommandName = 'Add-ADGroupMember'
            Times = 0
            Scope = 'It'
            Exactly = $true
        }
        Assert-MockCalled @assMParams

    }
}

describe 'Sync-AdUser - inactive employee tests' {

     mock 'Get-ActiveEmployee' {
        $getActiveEmployeeOutput
    }

    mock 'Test-ADUserExists' {
        $true
    }

    mock 'Test-ADOrganizationalUnitExists' {
        $true
    }

    mock 'Test-AdGroupExists' {
        $true
    }

    ## This is what we're testing around now
    mock 'Add-ADGroupMember'

    mock 'New-CompanyAdUser'

    mock 'Get-AdUserDefaultPassword' {
        (ConvertTo-SecureString -String 'foo' -AsPlainText -Force)
    }

    mock 'Disable-AdAccount'

    mock 'Write-Warning'

    ## Here I'm using contexts to create two mock scopes. I do this because I need to mock Get-InactiveEmployee to return
    ## two different outputs
    context 'No inactive employees' {

        mock 'Get-InactiveEmployee'

        $null = & $scriptFilePath

        it 'when there are no inactive employees it should do nothing' {
        
            $assMParams = @{
                CommandName = 'Disable-AdAccount'
                Times = 0
                Exactly = $true
            }
            Assert-MockCalled @assMParams

        }
    }

    context 'Active employees' {

        mock 'Get-InactiveEmployee' {
            $getInActiveEmployeeOutput
        }

        $null = & $scriptFilePath

        it 'should call Disable-AdAccount with the expected parameters for each inactive employee' {

            foreach ($emp in $getInActiveEmployeeOutput) {

                $assMParams = @{
                    CommandName = 'Disable-AdAccount'
                    Times = 1
                    Exactly = $true
                    #ParameterFilter = { $Identity -eq $emp.ADUserName }
                }
                Assert-MockCalled @assMParams

            }
        }
    }
    
}

#endregion