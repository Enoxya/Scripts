$Rapport = @()
$Datastores = Get-Datastore | Where-Object {$_.name -like '*VPLEX*'} | Sort-Object
    Foreach ($Datastore in $Datastores){
        $VMs = $Datastore | Get-VM
            Foreach ($VM in $VMs){
                #$Line = "" | Select-Object Name, vCPU, 'Memory(GB)', TotalHDD, Cluster, Folder, Datastore, 'Datastore Capacity'
                $Line = "" | Select-Object Name, Host, Datastore
                $Line.Name                 = $VM.Name
                $Line.Host                 = Get-VMHost -VM $VM.Name
                #$Line.vCPU                 = $VM.NumCpu
                #$Line.'Memory(GB)'         = $VM.MemoryGB
                #$Line.TotalHDD             = ($VM | Get-HardDisk | Measure-Object capacityGB -sum).sum
                #$Line.Cluster              = Get-Cluster -VM $VM.Name
                #$Line.Folder               = $VM.Folder
                $Line.Datastore            = $datastore.name
                #$Line.'Datastore Capacity' = $Datastore.CapacityGB
                $Rapport                   += $Line
            }
    }
$Rapport | Format-Table -AutoSize