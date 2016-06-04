describe 'talk tests' {
	
	$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\User Group Talks\Making Software Deployments Suck Less'
	
	$vms = @('DC', 'CLIENT1', 'CLIENT2', 'SCCM', 'MEMBERSRV1')
	
	it 'all VMs are online' {
		foreach ($vm in $vms)
		{
			Test-Connection -ComputerName $vm -Quiet -Count 1 | should be $true
		}
	}
		
	it 'all VMs have WinRM accessible' {
		
		$vms = @('CLIENT1', 'CLIENT2', 'SCCM', 'MEMBERSRV1')
		
		foreach ($vm in $vms)
		{
			Invoke-Command -ComputerName $vm -ScriptBlock {1} | should be 1
		}
	}
	
	it 'SoftwareInstallManager module is on MEMBERSRV1' {
		Test-Path '\\MEMBERSRV1\Packages\SoftwareInstallManager' -PathType Container | should be $true
	}
	
	it 'no packages exists in the packages share on MEMBERSRV1' {
		(Get-ChildItem \\MEMBERSRV1\Packages -Exclude 'SoftwareInstallManager' | where {$_.PSIsContainer}).Count | should be 0
	}
	
	it 'the New-CMApplication script is available' {
		Test-Path -Path '\\SCCM\c$\New-CMMyApplication.ps1' | should be $true
	}
	
	it 'source package exists locally (on SCCM)' {
		Test-Path -Path '\\SCCM\Packages\Microsoft_EMET' | should be $true
	}
	
	it 'CMTrace is available' {
		Test-Path -Path "$demoPath\CMTrace.exe" | should be $true
	}
	
	it 'can WinRm to SCCM' {
		Invoke-Command -ComputerName SCCM -ScriptBlock {1} | should be 1
	}
	
	it 'all VMs have snapshots' {
		$vms = @('CLIENT1', 'CLIENT2', 'SCCM')
		(Invoke-Command -ComputerName HYPERVSRV -ScriptBlock {Get-VM $using:vms | Get-VMSnapshot}).Count | should be 3
	}
	
	it 'the PowerShell scripts exist locally (on SCCM)' {
		(Get-ChildItem -Path "\\sccm\c$\packages\Microsoft_EMET" -Filter '*.ps1').Name | should be @('install.ps1', 'detect.ps1', 'uninstall.ps1')
	}
	
	it 'log files do not exist on clients' {
		$vms = @('CLIENT1', 'CLIENT2')
		$vms | foreach { Test-Path "\\$_\c$\windows\temp\softwareinstallmanager.log" | should be $false}
	}
	
	it 'the pre-created demo EMET app is setup' {
		Invoke-Command -ComputerName SCCM -ScriptBlock {
			Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -wv SilentlyContinue; cd LAB:; Get-CMApplication |
			where { $_.LocalizedDisplayName -eq 'Enhanced Mitigation Experience Toolkit' }
		} | should not benullorempty
	}
	
	it 'the EMET app is not already setup' {
		Invoke-Command -ComputerName SCCM -ScriptBlock {
			Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -wv SilentlyContinue; cd LAB:; Get-CMApplication |
			where { $_.LocalizedDisplayName -eq 'Enhanced Mitigation Experience Toolkit-Demo' }
		} | should benullorempty
	}
}