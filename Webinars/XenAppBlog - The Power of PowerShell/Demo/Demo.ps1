#region Demo Setup (DEMO purposes only)
$vms = Get-VM -ComputerName hyperv -Name 'win7x64','win8x86'
$vms | Start-VM
$vms | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false
del '\\win7x64\c$\windows\temp\*' -Recurse -ea SilentlyContinue
del '\\WIN81X86-1\c$\windows\temp\*' -Recurse -ea SilentlyContinue
$DemoPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\XenAppBlog - The Power of PowerShell\Demo'
ise "$DemoPath\LaunchScript.ps1"
ise "$DemoPath\SoftwareInstallManager\SoftwareInstallManager.psm1"
ise "$DemoPath\NSClient++\install.ps1"
#endregion

## Check out the Software package path
start "$DemoPath\NSClient++"

## Launch the deployment
& "$DemoPath\LaunchScript.ps1" -Client 'WIN7X64','WIN81x86-1' -Type Install -SwPackagePath "$DemoPath\NSClient++" -Verbose

## Check out the launch script and SoftwareInstallManager module

## Check out the install logs --notice the Win7 installed the x64 version and Win8.1 installed x86
## System Center 2012 R2 Configuration Manager Toolkit (CMTrace) HIGHLY RECOMMENDED!!
start '\\win7x64\c$\windows\temp'
start '\\WIN81X86-1\c$\windows\temp'