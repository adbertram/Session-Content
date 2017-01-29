param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$CsvFilePath
)

if ($PSBoundParameters.ContainsKey('CsvFilePath'))
{
    $activeEmployees = Get-ActiveEmployee @getEmpParams
} else {
    $activeEmployees = Get-ActiveEmployee
}

foreach ($emp in $activeEmployees) {
    try {
        if (Test-ADUserExists -Username $emp.ADUsername) {
            Write-Warning "The username [$($emp.ADUsername)] is not available. Cannot create account."
        } else {
            if (-not (Test-ADOrganizationalUnitExists -OUPath "OU=$($emp.Department)")) {
                throw "Unable to find the OU [$($departmentOuPath)]."
            } else {
                New-CompanyAdUser -Employee $emp -Username $emp.ADUsername -OrganizationalUnit $deptOuDn
            }

            if (-not (Test-AdGroupExists -Name $emp.Department)) {
                throw "Unable to find the group [$($emp.Department)]"
            } elseif (-not (Test-AdGroupMemberExists -Username $emp.ADUsername -GroupName $emp.Department)) {
                 Add-ADGroupMember -Identity $emp.Department -Members $emp.ADUsername
            }

        }
    } catch {
        Write-Error -Message $_.Exception.Message
    }
}

if ($inactiveEmployees = Get-InactiveEmployee) {
    foreach ($emp in $inactiveEmployees) {
        Write-Verbose -Message "Disabling inactive AD user [$($emp.ADUsername)]"
        $emp | Disable-AdAccount
    }
} else {
    Write-Verbose -Message "Found no inactive employees in AD."
}