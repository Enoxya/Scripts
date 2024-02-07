#Add-PSSnapin VMware.VimAutomation.Core
#Add-PSSnapin VMware.PowerCLI
$From = "testscriptPS@ch-bourg.ght01.fr"
$To = "sylvain.saunier@ch-bourg.ght01.fr"
$Smtp = "smtp.ght01.fr"

$ESXserver = "bob.sia-f.local"
$ESXUser = "sia-f.local\vCenter_SSAUNIER"
$ESXPwd = "+W{C'b[)av1?O,]"
 
Connect-VIServer $ESXserver -User $ESXUser -Password $ESXPwd
 
$VMArray = Get-VM
foreach ($VM in $VMArray) {
    $VMPoweredOn = $VM.PowerState
    $toolsStatus = $VM.ExtensionData.Guest.ToolsStatus
    if ($toolsStatus -ne "toolsOK" -and $VMPoweredOn -eq "PoweredOn") {
        $MailString = "Les vmtools sur la machine '$VM' remontent avec le statut inhabituel suivant : '$toolsStatus'.`r`n"
        $ContenuMail += $MailString
    }
}
Send-MailMessage -From $From -To $To -Subject "CHB - VIRT - VM - VMTools en statut anormal" -SmtpServer $Smtp -Body $ContenuMail