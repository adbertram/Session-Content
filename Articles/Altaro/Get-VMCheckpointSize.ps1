## Find all VMs that have a snapshot
Get-VM | where {$_.ParentSnapshotId } | ForEach-Object {
	## Create a hashtable to store all the output properties
	$output = [ordered]@{
		'VMName' = $_.Name
	}
	## Get the size of both the BIN and VSV files in the VHD's snapshot folder
	$output.'SnappedMemorySize (GB)' = [math]::Round((Get-ChildItem -Path "$($_.SnapshotFileLocation)\Snapshots\$($_.ParentSnapshotId)" -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
	## Get the size of the differencing disk (AVHDX) for the VM
	$output.'DiffDiskSize (GB)' = ($_.harddrives.path | foreach { get-item $_ } | Measure-Object -Property length -Sum).sum / 1GB
	[pscustomobject]$output
}