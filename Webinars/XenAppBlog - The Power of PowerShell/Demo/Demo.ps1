## Start up the clients and restore the latest snaps --launch as local admin (DEMO purposes only)
Get-VM -ComputerName hyperv -Name 'Windows*' | Start-VM
Get-VM -ComputerName hyperv -Name 'Windows*' | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false

## Check out the Software package path
ise "$DemoPath\NSClient++\install.ps1"

## Launch the deployment
$DemoPath = 'C:\Dropbox\Business Projects\Webinars\XenAppBlog - The Power of PowerShell\Demo'
& "$DemoPath\LaunchScript.ps1" -Client 'WIN7X64','WIN81x86-1' -Type Install -SwPackagePath "$DemoPath\NSClient++" -Verbose

## Check out the launch script
start "$DemoPath\LaunchScript.ps1"

## Check out the install logs --notice the Win7 installed the x64 version and Win8.1 installed x86
start '\\win7x64\c$\windows\temp'
start '\\WIN81X86-1\c$\windows\temp'