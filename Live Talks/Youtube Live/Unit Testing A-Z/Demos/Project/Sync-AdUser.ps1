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

if (-not $activeEmployees) {
    throw 'No employees found in CSV file'
}

foreach ($emp in $activeEmployees) {
    try {
        if (Test-ADUserExists -Username $emp.ADUsername) {
            Write-Warning -Message "The username [$($emp.ADUsername)] is not available. Cannot create account."
        } else {
            if (-not (Test-ADOrganizationalUnitExists -DistinguishedName $emp.OUPath)) {
                throw "Unable to find the OU [$($emp.OUPath)]."
            } else {
                Write-Verbose -Message "Creating AD username [$($emp.ADUsername)]..."
                New-CompanyAdUser -Employee $emp -Username $emp.ADUsername -OrganizationalUnit $emp.OUPath
            }
            if (-not (Test-AdGroupExists -Name $emp.Department)) {
                throw "Unable to find the group [$($emp.Department)]"
            } elseif (-not (Test-AdGroupMemberExists -Username $emp.ADUsername -GroupName $emp.Department)) {
                 Write-Verbose -Message "Adding username [$($emp.ADUsername)] to group [$($emp.Department)]..."
                 Add-ADGroupMember -Identity $emp.Department -Members $emp.ADUsername
            } else {
                Write-Verbose -Message "The username [$($emp.ADUsername)] is already a member of group [$($emp.Department)]."
            }

        }
    } catch {
        Write-Error -Message $_.Exception.Message
    }
}

if ($inactiveEmployees = Get-InactiveEmployee) {
    foreach ($emp in $inactiveEmployees) {
        Write-Verbose -Message "Disabling inactive AD user [$($emp.ADUsername)]"
        Disable-AdAccount -Identity $emp.ADUserName
    }
} else {
    Write-Verbose -Message "Found no inactive employees in AD."
}