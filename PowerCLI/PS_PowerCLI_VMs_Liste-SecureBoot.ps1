$ViServer = "gigi2.chb.ts1.local"

$ret = @()
Connect-VIServer $ViServer
$vms = get-vm

foreach ($vm in $vms) {
$ret += [PSCustomObject]@{
VMname = $vm.Name
VMOS = $vm.Guest.OsFullname
SecureBootValue = $vm.ExtensionData.Config.BootOptions.EfiSecureBootEnabled
}

}
DisConnect-VIServer $ViServer -confirm:$false
$ret | Export-Csv -Path C:\Users\chb_ssaunier\Desktop\VMs_SecureBoot.csv -NoTypeInformation