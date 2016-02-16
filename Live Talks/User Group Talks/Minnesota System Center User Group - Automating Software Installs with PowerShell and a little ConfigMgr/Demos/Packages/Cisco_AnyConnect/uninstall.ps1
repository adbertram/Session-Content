Import-Module \\MEMBERSRV1\Packages\SoftwareInstallManager
Start-Log
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

$InstallLocation = "$(Get-32BitProgramFilesPath)\Cisco\Cisco NAC Agent"

Get-InstalledSoftware -Name 'Cisco NAC Agent' | Remove-Software -RemoveFolder "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco NAC Agent", "$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco NAC Agent" -RemoveRegistryKey 'HKLM:\Software\Cisco\Cisco NAC Agent', 'HKCU:\Software\Cisco\Cisco NAC Agent'
Get-InstalledSoftware -Name 'Cisco AnyConnect Secure Mobility Client' | Remove-Software -RemoveFolder $InstallLocation, "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco NAC Agent","$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco AnyConnect Secure Mobility Client" -RemoveRegistryKey 'HKCU:\Software\Cisco\Cisco AnyConnect Secure Mobility Client'
Get-InstalledSoftware -Name 'Cisco AnyConnect Diagnostics and Reporting Tool' | Remove-Software
Get-InstalledSoftware -Name 'Cisco AnyConnect Network Access Manager' | Remove-Software

if ((Get-OperatingSystem) -match 'XP') {
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'GinaDLL' -Value 'ALTUSGINA'
}
