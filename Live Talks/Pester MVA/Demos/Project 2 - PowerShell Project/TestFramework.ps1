describe 'Get-AdUserDefaultPassword' {

    it 'builds the default FilePath parameter correctly and passes it to Import-CliXml' {

    }

    it 'returns a single secure string' {
               
    }

    it 'converts the expected password to a secure string' {

    }
}

describe 'Get-ActiveEmployee' {

    it 'returns the expected number of objects' {        

    }

    it 'returns objects that have an ADuserName property appended' {
        
    }

    it 'returns objects that have an OUPath property appended' {

    }

    it 'throws an exception when the CSV file cannot be found' {

    }


    it 'builds the default FilePath parameter correctly and passes it to Import-Csv' {

    }
}

describe 'Get-InactiveEmployee' {

    it 'should only query for AD users that are enabled' {

    }

    it 'should exclude the domain administrator account from the AD user query' {
    
    }

    it 'should only return AD users that are not in the CSV file' {

    }   
}

describe 'Get-EmployeeUsername' {

    it 'should return a single string' {

    }
    
    it 'should return the first initial of the first name as the first character' {
    
    }

    it 'should return the expected username' {
    
    }
}

describe 'Get-DepartmentOUPath' {


    it 'returns a single string' {

    } 

    it 'returns the expected OU path' {

    }
}

describe 'Test-AdUserExists' {
    
    it 'returns $true if the user account can be found in AD' {

    }

    it 'returns $false if the user account cannot be found in AD' {

    }
}

describe 'Test-AdGroupExists' {

    it 'returns $true if the group can be found in AD' {

    }

    it 'returns $false if the group cannot be found in AD' {

    }
}

describe 'Test-AdGroupMemberExists' {

    it 'returns $true if the username is a member of the group' {

    }

    it 'returns $false if the username is not a member of the group' {

    }
}

describe 'Test-ADOrganizationalUnitExists' {
    
    it 'creates the proper full OU DN and passes to Get-ADOrganizationalUnit' {

    }

    it 'returns $true if the group can be found in AD' {


    }

    it 'returns $false if the group cannot be found in AD' {

    }
}

describe 'New-CompanyAdUser' {

    it 'should attempt to create an AD user with the proper parameters' {

    }
}