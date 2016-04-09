## Bring up CMTrace.  CMTrace is great for formatting, real-time log analysis, etc
& "C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe"

## Show log levels
Import-Module \\LABDC.LAB.LOCAL\Deployments\SoftwareInstallManager.psm1
Start-Log

Write-Log -Message 'something normal'
Write-Log -Message 'Something moderate' -LogLevel 2
Write-Log -Message 'something bad' -LogLevel 3
start (Get-SystemTempFolderPath)