#region Demo Setup (DEMO purposes only)
## Start up the clients and restore the latest snaps
$vms = Get-VM -ComputerName hyperv -Name 'win7x64','win8x86'
$vms | Start-VM
$vms | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false
#endregion

$DemoPath = 'C:\Dropbox\GitRepos\Session-Content\Webinars\XenAppBlog - The Power of PowerShell\Demo'

## Check out the Software package path
ise "$DemoPath\NSClient++\install.ps1"

## Launch the deployment
& "$DemoPath\LaunchScript.ps1" -Client 'WIN7X64','WIN81x86-1' -Type Install -SwPackagePath "$DemoPath\NSClient++" -Verbose

## Check out the launch script
ise "$DemoPath\LaunchScript.ps1"

## Check out the install logs --notice the Win7 installed the x64 version and Win8.1 installed x86
## System Center 2012 R2 Configuration Manager Toolkit (CMTrace) HIGHLY RECOMMENDED!!
start '\\win7x64\c$\windows\temp'
start '\\WIN81X86-1\c$\windows\temp'