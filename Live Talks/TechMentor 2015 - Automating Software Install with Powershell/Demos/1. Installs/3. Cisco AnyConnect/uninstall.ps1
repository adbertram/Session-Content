Import-Module \\configmanager\deploymentmodules\SoftwareInstallManager
if ((Get-OperatingSystem) -notmatch 'XP') {
	Import-Module \\configmanager\deploymentmodules\MSI
}
$WorkingDir = $MyInvocation.MyCommand.Path | Split-Path -Parent
Start-Log

$MobilityClientInstallLoc = Get-InstallLocation -ProductName 'Cisco AnyConnect Secure Mobility Client'

Get-InstalledSoftware -Name 'Cisco NAC Agent' | Remove-Software -RemoveFolder "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco NAC Agent", "$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco NAC Agent" -RemoveRegistryKey 'HKLM:\Software\Cisco\Cisco NAC Agent', 'HKCU:\Software\Cisco\Cisco NAC Agent'
Get-InstalledSoftware -Name 'Cisco AnyConnect Secure Mobility Client' | Remove-Software -RemoveFolder $MobilityClientInstallLoc, "$(Get-AllUsersProfileFolderPath)\Cisco\Cisco NAC Agent","$(Get-AllUsersProfileFolderPath)\Application Data\Cisco\Cisco AnyConnect Secure Mobility Client" -RemoveRegistryKey 'HKCU:\Software\Cisco\Cisco AnyConnect Secure Mobility Client'
Get-InstalledSoftware -Name 'Cisco AnyConnect*' | Remove-Software

if ((Get-OperatingSystem) -match 'XP') {
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'GinaDLL' -Value 'ALTUSGINA'
}

#Start-Process -FilePath "$(Get-InstallLocation -ProductName 'Cisco AnyConnect Secure Mobility Client')\Uninstall.exe" -ArgumentList '-remove -silent' -NoNewWindow -Wait
#Get-InstalledSoftware -Name 'Cisco AnyConnect Diagnostics and Reporting Tool' | Remove-Software
#Start-Process -FilePath 'msiexec.exe' -ArgumentList '/x{3657178B-CDB0-46B0-8C43-E1FB50DA313D} /qn' -NoNewWindow -Wait