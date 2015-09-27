Import-Module C:\MyDeployment\SoftwareInstallManager.psm1
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
$VersionToKeep = @{ 'NumericVersion' = '6.0.200'
                    'NameVersion' = 'Java(TM) 6 Update 20'
                }
 
Stop-MyProcess -ProcessName 'iexplore'
 
Get-InstalledSoftware | Where-Object { ($_.Name -match 'Java\(TM\)') -and ($VersionToKeep.NumericVersion -ne $_.Version)} | Remove-Software
 
$null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
$ClassesRootPath = 'HKCR:\Installer\Products'

$WhereBlock = { ($_.GetValue('ProductName') -match '.+Java.+[6-8].+') -and ($VersionToKeep.NameVersion -ne $_.GetValue('ProductName')) }
Get-ChildItem $ClassesRootPath |  Where-Object $WhereBlock | Foreach { Remove-Item $_.PsPath -Force -Recurse }
 
 ## We're keeping no versions of Java so everything can be cleaned up.
 ## Leave the standard stuff behind if one or more versions are to be kept.
 if ($VersionsToKeep.Count -eq 0) {
    Write-Log -Message 'Cleaning up any remnants of Java registry keys'
    Remove-Item 'HKLM:\SOFTWARE\JavaSoft' -Force -Recurse -ErrorAction SilentlyContinue 
    Remove-Item "$env:Programfiles\Java" -Force -Recurse -ErrorAction SilentlyContinue
}
Write-Log -Message 'Java uninstall script complete'
