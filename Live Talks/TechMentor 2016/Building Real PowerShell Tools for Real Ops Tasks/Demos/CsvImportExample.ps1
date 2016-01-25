#region Demo setup

$demoFolderPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\TechMentor 2016\Building Real PowerShell Tools for Real Ops Tasks\Demos\2. Wasting Time with ADUC'

#endregion

## Dot source the functions
. "$demoFolderPath\AdAccountManagementAutomator.ps1"

$Employees = Import-Csv -Path C:\Users.csv
foreach ($Employee in $Employees) {
    ## Create the AD user accounts
    $NewUserParams = @{
        'FirstName' = $Employee.FirstName
        'MiddleInitial' = $Employee.MiddleInitial
        'LastName' = $Employee.LastName
        'Title' = $Employee.Title
    }
    if (!$Employee.Location) { 
        $NewUserParams.Location = $null 
    } else { 
        $NewUserParams.Location = $Employee.Location
    }
    ## Grab the username created to use for Set-MyAdUser
    $Username = New-EmployeeOnboardUser @NewUserParams

    ## Create the employee's AD computer account
    New-EmployeeOnboardComputer -Computername $Employee.Computername

    ## Set the description for the employee's computer account
    Set-MyAdComputer -Computername $Employee.Computername -Attributes @{'Description' = "$($Employee.FirstName) $($Employee.LastName)'s computer" }

    ## Set the dept the employee is in
    Set-MyAdUser -Username $Username -Attributes @{'Department' = $Employee.Department}
}

## Verify it worked with ADUC
dsa.msc