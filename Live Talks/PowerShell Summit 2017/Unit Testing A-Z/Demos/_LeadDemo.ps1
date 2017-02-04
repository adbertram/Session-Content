<# 
Unit tests do x things:
     - Ensures the code "flows" as you'd expect given different inputs
     - Ensure bugs aren't introduced when code changes
     - Increases trust in your code
     - Keep you from doing something stupid

Demo Path
===========
Introduction
 - Pester basics
 - Kicking the tires
 - Getting used to syntax
 
 Building real tests (CSV --> AD Sync script)
  - Read names from CSV --> create new AD account, etc
  - Start with an example of untestable script
  - Refactor script using dot sourcing
  - Use refactored script using module
#>

$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos'
$talkPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z'

## What unit tests really help with
    ii "$talkPath\Mindset\CodeChanges.ps1"
    ii "$talkPath\Mindset\DoingSomethingStupid.ps1"
    ii "$talkPath\Mindset\IncreasingTrust.ps1"

#region Begin Introduction
    ii "$demoPath\Introduction\MyScriptv1.ps1"
    ii "$demoPath\Introduction\MyScriptv1.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Introduction\MyScriptv1.Tests.ps1"

    ii "$demoPath\Introduction\MyScriptv2.ps1"
    ii "$demoPath\Introduction\MyScriptv2.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Introduction\MyScriptv2.Tests.ps1"
#endregion

## Run Pester tests to ensure this demo is at the right state
& "$demoPath\PrepTests.ps1"
## & "$demoPath\PrepDemo.ps1"

## Start real tests (Post-break?)

    ## Introduce the problem and the script we start with. This script works I suppose but it's impossible to write unit tests against.
    ii "$demoPath\Project\Sync-AdUser-needswork.ps1"
    & "$demoPath\Project\Sync-AdUser-needswork.ps1" -Verbose

    ## Clean up AD --demo stuff
    & "$demoPath\PrepDemo.ps1"

    ## Refactor the script using a module
    ii "$demoPath\Project\Sync-AdUser.ps1"
    ii "$demoPath\Project\Module\AdUserSync.psm1"

    ## Script uses functions from our new module --build tests for both
    ii "$demoPath\Project\Module\AdUserSync.Tests.ps1"
    ii "$demoPath\Project\Sync-AdUser.Tests.ps1"

    ## Run tests
    Invoke-Pester -Path "$demoPath\Project\Module\AdUserSync.Tests.ps1"
    Invoke-Pester -Path "$demoPath\Project\Sync-AdUser.Tests.ps1"