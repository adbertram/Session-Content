#Requires -Version 4

$perfCounters = @(
	'\Hyper-V Virtual Storage Device({0})\Read Bytes/sec',
	'\Hyper-V Virtual Storage Device({0})\Write Bytes/sec',
	'\Hyper-V Virtual IDE Controller (Emulated)({0})\Read Bytes/sec',
	'\Hyper-V Virtual IDE Controller (Emulated)({0})\Write Bytes/sec'
)

Get-VM | where { $_.State -eq 'Running' } | ForEach-Object {
	$output = [ordered]@{'VMName' = $_.Name}
	foreach ($p in $perfCounters)
	{
		$output.Monitor = $p
		if ($p -like '\Hyper-V Virtual Storage Device*')
		{
			$instanceName = $_.harddrives.path.Replace('\', '-')
		}
		elseif ($p -like '\Hyper-V Virtual IDE Controller (Emulated)*')
		{
			$instanceName = "$($_.Name):ide controller"
		}
		$value = (Get-Counter -Counter ($p -f $instanceName)).CounterSamples.CookedValue
		$output.Value = $value
		[pscustomobject]$output
	}
} | Sort-Object -Property Value -Descending | select -First 5