describe 'TestEnvironment' {

    ## Read the expected attributes from ConfigurationData
    $expectedAttributes = Import-PowerShellDataFile -Path "$PSScriptRoot\ConfigurationData.psd1"
    
    $dcName = @($expectedAttributes.AllNodes[0]).where({ $_.Purpose -eq 'Domain Controller' -and $_.NodeName -ne '*' }).Nodename

    $sharedSession = New-PSSession -ComputerName $dcName

    ## Forest-wide
    $forest = Invoke-Command -Session $sharedSession -ScriptBlock { Get-AdForest }
    
    ## Groups
    $actualGroups = Invoke-Command -Session $sharedSession -ScriptBlock {  Get-AdGroup -Filter '*' } | Select -ExpandProperty Name
    $expectedGroups = $expectedAttributes.NonNodeData.AdGroups
    
    ## OUs
    $actualOuDns = Invoke-Command -Session $sharedSession -ScriptBlock { Get-AdOrganizationalUnit -Filter '*' } | Select -ExpandProperty DistinguishedName
    $expectedOus = $expectedAttributes.NonNodeData.OrganizationalUnits
    $expectedOuDns = $expectedOus | foreach { "OU=$_,DC=mylab,DC=local" }

    ## Users
    $actualUsers = Invoke-Command -Session $sharedSession -ScriptBlock { Get-AdUser -Filter "*" -Properties Department,Title }
    $expectedUsers = $expectedAttributes.NonNodeData.AdUsers

    it "creates the expected forest" {
        $forest.Name | should be $expectedAttributes.NonNodeData.DomainName
    }

    it 'creates all expected AD Groups' {

       @($actualGroups | where { $_ -in $expectedGroups }).Count | should be @($expectedGroups).Count

    }

    it 'creates all expected AD OUs' {
        
        @($actualOuDns | where { $_ -in $expectedOuDns }).Count | should be @($expectedOuDns).Count
        
    }

    it 'creates all expected AD users' {
        
        foreach ($user in $expectedUsers) {
            $expectedUserName = ('{0}{1}' -f $user.FirstName.SubString(0,1),$user.LastName)
            $actualUserMatch = $actualUsers | where {$_.SamAccountName -eq $expectedUserName}
            $actualUserMatch | should not benullorempty     
            $actualUserMatch.givenName | should be $user.FirstName
            $actualUserMatch.surName | should be $user.LastName
            $actualUserMatch.Department | should be $user.Department
            $actualUserMatch.DistinguishedName | should be "CN=$expectedUserName,OU=$($user.Department),DC=mylab,DC=local"
        }
    }
}

#region Teardown

## Here is where you'll place any code that essentially backs out any changes the code your testing has changed
## in your environment. Lucky for us, George just created a single VM and didn't do anything else so we can remove
## all traces of George's presence by just removing the VM and the VHD.

#$expectedVmName = Get-ExpectedValue -Path 'VirtualMachine\Name'
#$vm = Get-VM -Name $expectedVmName -ComputerName $hyperVHostName
#$vhd = $vm | Get-VMHardDiskDrive
#icm -computername $hyperVHostName -scriptblock { 
#    get-vm $using:expectedVmName | stop-vm -Passthru | remove-vm -Force
#    Remove-Item -Path $using:vhd.Path
#}

#endregion