## Demo stuff
    return
    $demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\Pester MVA\Demos'

##############################################
## Installing Pester
##############################################
    ## Github
    start https://github.com/pester/Pester

    ## PowerShell Gallery
    Find-Module -Name Pester
    Find-Module -Name Pester -RequiredVersion 3.4.6
    Install-Module -Name Pester -Force

    Get-Command -Module Pester

##############################################
## Project 1 - Simple TDD Example
##############################################
    <# Define what we want to do
        Create a function that parses a line of text from a file. We know what the function should return we just don't know
        how to do that yet. We'll build this function using TDD (test-driven development). This function will be called
        Test-Foo. For now, we'll just create a blank function to act as a placeholder.
    #>

    <# Define necessary potential outcomes
        If a text file contains the string 'foo', we need to return $true. If it does not, we need this function to return
        $false.
    #>

    ## Ensure the function is available in the session
    function Test-Foo {
        param(
            $FilePath
        )
    }

    ## A describe block with the same name as the function itself (recommended)
    describe 'Test-Foo' {

        # Arrange/Act step
            ## Since working with files, we'll use the builtin Pester feature TestDrive.
            ## Create a file that we know for sure has 'foo' in it
            Add-Content -Path TestDrive:\foofile.txt -Value 'foo'

            ## Create a file that we know for sure does not have 'foo' in it
            Add-Content -Path TestDrive:\nofoofile.txt -Value 'not here'

        ## The actual tests (it blocks) inside of the describe block. recommended to use a standard naming convention
        ## when X, it should Y. This is the "Assert" phase.

        it 'when the file has "foo" in it, it should return $true' {

            ## Should "asserts" what the function should return
            ## https://github.com/pester/Pester/wiki/Should
            $output = Test-Foo -FilePath TestDrive:\foofile.txt
            $output | should be $true
            $output | should beoftype 'bool'
            @($output).Count | should be 1

        }

        it 'when the file does not have "foo" in it, it should return $false' {

            ## Should "asserts" what the function should return
            Test-Foo -FilePath TestDrive:\nofoofile.txt | should be $false

        }
    }

    ## Run the tests --failed. Why?

    ## Let's now start adding in the code to make the function "real"

    function Test-Foo {
        param(
            $FilePath
        )

        if (Select-String -Path $FilePath -Pattern 'foo') {
            $true
        }
    }

    ## Great! One test passes. Let's make the next one pass

    function Test-Foo {
        param(
            $FilePath
        )

        if (Select-String -Path $FilePath -Pattern 'foo') {
            $true
        } else {
            $false
        }
    }

    ## Now let's bring all of this into a Pester test script
    ii "$demoPath\Test-Foo.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Test-Foo.Tests.ps1"

##############################################
## Mocking
##############################################

    ii "$demoPath\Mocking.ps1"

##############################################
## Project 2 - Writing Tests for a PowerShell Project
##############################################

    ## Run Pester tests to ensure this demo is at the right state
    & "$demoPath\Project 2 - PowerShell Project\PrepTests.ps1"
    ## & "$demoPath\PrepDemo.ps1"

    ## Introduce the problem and the script we start with. This script works I suppose but it's impossible to write unit tests against.
    ii "$demoPath\Project 2 - PowerShell Project\Sync-AdUser-needswork.ps1"
    & "$demoPath\Project 2 - PowerShell Project\Sync-AdUser-needswork.ps1" -Verbose

    ## Clean up AD --demo stuff
    & "$demoPath\Project 2 - PowerShell Project\PrepDemo.ps1"
    & "$demoPath\Project 2 - PowerShell Project\PrepTests.ps1"

    ##############################################
    ## Step #1: Readying code for testing
    ##############################################
        <# 
            1. Discover each "thing" that the code is doing. This is a MUST!

            Our script is:

            - Getting the default user password for all new accounts
            - Finding all active employees (employees in CSV from HR)
            - Figuring out the username for an employee
            - Testing to see if the required AD account already exists
                - If so, skips it
                - If not:
                    - Figures out the OU path for the department the employee is in
                    - Ensures that OU exists
                        - If not: throws an exception
                        - If so, creates the AD account
                - Ensure the department group exists
                    - If not: throws an exception
                    - If so:
                        - Checks to see if the account is already a member
                        - If so, skips.
                        - If not, adds the account to the group.
            - Looks for any employee accounts in AD that aren't in the CSV file
                - If none found, script ends
                - If any found, disables them
        #>

        ## 2. Create functions for each specific task
        ii "$demoPath\Project 2 - PowerShell Project\Module\AdUserSync.psm1"

        ## 3. Refactor script to use new functions
        ii "$demoPath\Project 2 - PowerShell Project\Sync-AdUser.ps1"

    ##############################################
    ## Step #2: Building the tests
    ##############################################

        ## 1. Build a test 'framework' for all module functions (helpers)
        ii "$demoPath\Project 2 - PowerShell Project\TestFramework.ps1"

        ## 2. Build tests for our "helper" functions in the module
        ii "$demoPath\Project 2 - PowerShell Project\Module\AdUserSync.Tests.ps1"

        ## 3. Build tests for how these functions are invoke in the script
        ii "$demoPath\Project 2 - PowerShell Project\Sync-AdUser.Tests.ps1"


    ##############################################
    ## Project Completed
    ##############################################

    ## Remove all of the stuff we did to the environment to prove a point
     & "$demoPath\Project 2 - PowerShell Project\PrepDemo.ps1"

    ## Run tests
    Invoke-Pester -Path "$demoPath\Project 2 - PowerShell Project\Module\AdUserSync.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Project 2 - PowerShell Project\Sync-AdUser.Tests.ps1"

##############################################
## Testing DSC
##############################################


##############################################
## Project 3 - Automating DSC Configuration Tests
##############################################






