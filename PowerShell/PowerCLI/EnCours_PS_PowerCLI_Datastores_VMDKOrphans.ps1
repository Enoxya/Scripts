#Add-PSSnapin VMware.VimAutomation.Core
#Add-PSSnapin VMware.PowerCLI
 
.\PowerShell\PowerCLI\PS_PowerCLI_vCenter_Connexion-Infos.ps1

$vmdkds=@()
$vmdkvm=@()
Write-Host "Parsing all datastores and VMDKs. This might take a while.`r`n"
$dslist = Get-View -ViewType Datastore | Select-Object Name
foreach($ds in $dslist) {
    $vmdks = Get-HardDisk -Datastore $ds.Name
        foreach($vmdk in $vmdks) {
            $vmdkfilename = @{Filename = $vmdk.Filename}
            $vmdkentry = New-Object PSObject -Property $vmdkfilename
            $vmdkds+=$vmdkentry
        }
    }
    $vmlist = Get-View -ViewType VirtualMachine | Select-Object Name
    foreach($vm in $vmlist) {
        $vmdks = Get-HardDisk -VM $vm.Name
        foreach($vmdk in $vmdks) {
            $vmdkfilename = @{Filename = $vmdk.Filename}
            $vmdkentry = New-Object PSObject -Property $vmdkfilename
            $vmdkvm+=$vmdkentry
        }
    }
Write-Host "Done. Now processing. Please wait.`r`n"
Compare-Object $vmdkvm $vmdkds -Property Filename | Where-Object { $_.SideIndicator -eq "=>" } | foreach-object { Write-Host $_.InputObject }