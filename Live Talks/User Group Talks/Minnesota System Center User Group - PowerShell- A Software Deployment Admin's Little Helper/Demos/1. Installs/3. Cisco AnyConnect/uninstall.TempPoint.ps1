Import-Module \\configmanager\deploymentmodules\SoftwareInstallManager
Start-Log

Start-Process -FilePath "$(Get-InstallLocation -ProductName 'Cisco AnyConnect Secure Mobility Client')\Uninstall.exe" -ArgumentList '-remove -silent' -NoNewWindow -Wait
Get-InstalledSoftware -Name 'Cisco AnyConnect Diagnostics and Reporting Tool' | Remove-Software
Start-Process -FilePath 'msiexec.exe' -ArgumentList '/x{3657178B-CDB0-46B0-8C43-E1FB50DA313D} /qn' -NoNewWindow -Wait