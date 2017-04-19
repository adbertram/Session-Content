$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\Youtube Live\Infrastructure Testing with Pester\Demos'

## Read the expected attributes from ConfigurationData
$expectedAttributes = Import-PowerShellDataFile -Path "$demoPath\Project\ConfigurationData.psd1"
	
## Reuse DSC's configuration data here. This way we know already what to expect
$expectedDomainControllerName = @($expectedAttributes.AllNodes).where({ $_.Purpose -eq 'Domain Controller' -and $_.NodeName -ne '*' }).Nodename

## Example of gathering actual and expected AD groups
#$actualGroups = Invoke-Command -ComputerName 'FOO' -ScriptBlock {  Get-AdGroup -Filter '*' } | Select -ExpandProperty Name
$expectedGroups = $expectedAttributes.NonNodeData.AdGroups