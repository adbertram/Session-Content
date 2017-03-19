#region Dependency checking and remediation
$hyperVCred = (Import-Clixml -Path "$PSScriptRoot\HyperVCredential.xml")
$hyperVSrv = 'HYPERVSRV'

<#
## We'll implement 3 actions

- Check to see if the dependency is there
- If not:
  - Either stop the tests from being performed in the first place
  - Implement code to satisfy that dependency
- If any dependencies had to be satisfied, make the environment in the same state as we found it
#>

## Define all dependencies in some kind of order. Here I'm using a hashtable.
## Each key has another hashtable with three keys; CheckAction, RemediationAction and RemoveAction
## This allows us to keep track of what actions to perform and when.
$dependencies = [ordered]@{
	'VM is created' = @{
		CheckAction = {
			$vmCheck = { 
				if (Get-VM -Name $using:expectedVmName -ErrorAction 'SilentlyContinue')
				{
					$true
				}  else
				{
					$false
				}
			}
			Invoke-Command -ComputerName $hyperVSrv -ScriptBlock $vmCheck 
		}
		RemediationAction = {
			throw 'VM creation remediation code not yet implemented. Laziness in full effect.'
		}
		RemoveAction = {
			Invoke-Command -ComputerName $hyperVSrv -ScriptBlock { Get-VM -Name $using:expectedVmName | Get-VMSnapshot | Restore-VmSnapshot }
		}
	}
	'VM is running' = @{
		CheckAction = {
			$vmCheck = { 
				if (Get-VM -Name $using:expectedVmName -ErrorAction 'SilentlyContinue' | where { $_.State -eq 'Running' })
				{
					$true
				}  else
				{
					$false
				}
			}
			Invoke-Command -ComputerName $hyperVSrv -ScriptBlock $vmCheck 
		}
		RemediationAction = {
			Invoke-Command -ComputerName $hyperVSrv -ScriptBlock { Get-VM -Name $using:expectedVmName | Start-Vm }
			## Wait for it to boot
			while (-not (Test-Connection -ComputerName $expectedVmName -Quiet -Count 1)) {
				Start-Sleep -Seconds 5
			}
		}
		RemoveAction = {
			Invoke-Command -ComputerName $hyperVSrv -ScriptBlock { Get-VM -Name $using:expectedVmName | Stop-Vm }
		}
	}
	'VM can be found by name' = @{
		CheckAction = {
			(Resolve-DnsName -Name $expectedDomainControllerName -ErrorAction 'SilentlyContinue') -ne $null
		}
		RemediationAction = {
			Write-Warning -Message 'No specific remediation necessary for DNS problem. You have probably got bigger problems.'
		}
		RemoveAction = {
			Write-Verbose -Message 'No specific remove action necessary for DNS problem.'
		}  
	}
	'VM is pingable' = @{
		CheckAction = {
			Test-Connection -ComputerName $expectedDomainControllerName -Quiet -Count 1
		}
		RemediationAction = {
			throw 'VM is running but it is not pingable. This is where I might do something to the VM firewall.'
		}
		RemoveAction = {
			Write-Verbose -Message 'No specific remove action necessary for unpingable (is that a word?) VM.'
		}
			
	}
	'VM has PS Remoting available' = @{
		CheckAction = {
			(Invoke-Command  -ComputerName $expectedDomainControllerName -ScriptBlock {1}) -eq 1
		}
		RemediationAction = {
			throw 'VM cannot be remoted to. This is where I might try to enable WinRM.'
		}
		RemoveAction = {
			Write-Verbose -Message 'No specific remove action necessary for unresponsive PS remoting VM.'
		}
	}
}

Write-Host @whParams -Object "====Start Dependency Check====" -ForegroundColor Magenta

## Give the user an option to just fail checks or build the deps
$DependencyFailureAction = 'Exit'

## Since all deps are in a hashtable, we can just iterate over each one and perform the check
$script:removeActions = @()
foreach ($dep in $dependencies.GetEnumerator())
{
    Write-Host @whParams -Object "-Checking dependency [$($dep.Key)]..." -ForegroundColor Yellow

	## Ensuring that each check action either ends in true or false, we can make an assessment if it succeeded or failed	
    if (-not (& $dep.Value.CheckAction))
    {
        if ($DependencyFailureAction -eq 'Exit')
        {
            throw "The dependency [$($dep.Key)] failed. Halting tests.."
        } else
        {
            Write-Host @whParams -Object "---The dependency [$($dep.Key)] failed but hold on. I am remediating this..." -ForegroundColor Cyan
            $script:removeActions += $dep.Value.RemoveAction
            & $dep.Value.RemediationAction
        }
    } 
    else
    {
        Write-Host @whParams -Object "---The dependency [$($dep.Key)] passed." -ForegroundColor Green
    }
}
Write-Host @whParams -Object "====End Dependency Check====" -ForegroundColor Magenta
#endregion