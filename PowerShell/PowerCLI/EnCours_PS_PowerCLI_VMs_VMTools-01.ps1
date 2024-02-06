#Add-PSSnapin VMware.VimAutomation.Core
#Add-PSSnapin VMware.PowerCLI
$From = "admin-vmw@localhost"
$To = "supervision@localhost"
$Smtp = "smtp.localdomain"
$ESXServer = "esxi.localdomain"
$ESXUser = "service"
$ESXPwd = "P@ssw0rd"
 
Connect-VIServer $ESXserver -User $ESXUser -Password $ESXPwd
 
$VMArray = Get-VM
foreach ($VM in $VMArray) {
    $VMPoweredOn = $VM.PowerState
    $toolsStatus = $VM.ExtensionData.Guest.ToolsStatus
    if ($toolsStatus -ne "toolsOK" -and $VMPoweredOn -eq "PoweredOn") {
        $MailString = "Bonjour, les vmtools sur la machine '$VM' remontent avec le statut inhabituel suivant : '$toolsStatus'."
        Send-MailMessage -From $From -To $To -Subject "vmtools en statut anormal sur $VM" -SmtpServer $Smtp -Body $MailString
    }
}