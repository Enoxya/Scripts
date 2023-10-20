
$report = @()
$Datastore = Read-Host "Name of the Datastore"
$DS = get-Datastore -Name $Datastore
$VMs = $DS | Get-VM

Foreach ($VM in $VMs) {
    $line = "" | Select-Object Cluster, 'VM Name', 'DataStore Name', 'DS FreeSpace - GB', 'DS Capacity - GB', 'DS VM Number'
    $line.Cluster = Get-Cluster -VM $VM.Name
    $line.'VM Name' = $VM.Name
    $line.'DataStore Name' = $DS.Name
    $line.'DS Capacity - GB' = $DS.CapacityGB
    $line.'DS FreeSpace - GB' = [math]::Round($($DS.FreeSpaceGB),2)
    $line.'DS VM Number' = ($DS.ExtensionData.VM).Count
    $report += $line
}

$report | Format-Table -AutoSize

