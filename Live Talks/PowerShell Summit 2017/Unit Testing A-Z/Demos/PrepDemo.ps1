$artifactsFolder = "C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Unit Testing A-Z\Demos\Project\Artifacts"
$employeesCsvPath = "$artifactsFolder\Employees.csv"

$csvEmployees = Import-Csv -Path $employeesCsvPath

foreach ($emp in $csvEmployees) {
    $firstInitial = $emp.FirstName.SubString(0,1)
    $userName = '{0}{1}' -f $firstInitial,$emp.LastName
			
    Get-AdUser -Filter "samAccountName -eq '$userName'" | Remove-AdUser -Confirm:$false
}
