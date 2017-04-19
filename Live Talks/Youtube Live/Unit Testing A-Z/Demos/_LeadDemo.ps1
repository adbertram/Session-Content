## Demo stuff
    return
    $demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos'
    $talkPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z'

######################
Invoke-Pester "$talkPath\Presentation.Tests.ps1"

##############################################
## Pester Syntax Intro
##############################################
    ise "$demoPath\Introduction\MyScriptv1.ps1"

    & "$demoPath\Introduction\MyScriptv1.ps1" -Number 5

    ise "$demoPath\Introduction\MyScriptv1.Tests.ps1"

    ## Works! Great!
    Invoke-Pester -Path "$demoPath\Introduction\MyScriptv1.Tests.ps1"

    ise "$demoPath\Introduction\MyScriptv2.ps1"
    ise "$demoPath\Introduction\MyScriptv2.Tests.ps1"

    ## Works! Great!
    Invoke-Pester -Path "$demoPath\Introduction\MyScriptv2.Tests.ps1"

    ## Lemme do just this little tweak.. shouldn't affect anything

    ## GOTO Next slide

##############################################
## Mocking
##############################################

    ise "$demoPath\Introduction\Mocking.ps1"

    ## GOTO Next slide

##############################################
## Project Introduction
##############################################

    ## Run Pester tests to ensure this demo is at the right state
    & "$demoPath\PrepTests.ps1"
    ## & "$demoPath\PrepDemo.ps1"

    ## Introduce the problem and the script we start with. This script works I suppose but it's impossible to write unit tests against.
    ise "$demoPath\Project\Sync-AdUser-needswork.ps1"
    & "$demoPath\Project\Sync-AdUser-needswork.ps1" -Verbose

    ## Clean up AD --demo stuff
    & "$demoPath\PrepDemo.ps1"
    & "$demoPath\PrepTests.ps1"

##############################################
## Project Step #1: Readying code for testing
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
    ise "$demoPath\Project\Module\AdUserSync.psm1"

    ## 3. Refactor script to use new functions
    ise "$demoPath\Project\Sync-AdUser.ps1"

##############################################
## Project Step #2: Building the tests
##############################################

    ## 1. Build a test 'framework' for all module functions (helpers)
    ise "$demoPath\Project\TestFramework.ps1"

    ## 2. Build tests for our "helper" functions in the module
    ise "$demoPath\Project\Module\AdUserSync.Tests.ps1"

    ## 3. Build tests for how these functions are invoke in the script
    ise "$demoPath\Project\Sync-AdUser.Tests.ps1"


##############################################
## Project Completed
##############################################

    ## Remove all of the stuff we did to the environment to prove a point
     & "$demoPath\PrepDemo.ps1"

    ## Run tests
    Invoke-Pester -Path "$demoPath\Project\Module\AdUserSync.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Project\Sync-AdUser.Tests.ps1"

## GOTO Final slides