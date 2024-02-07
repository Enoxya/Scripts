
$From = "testscriptPS@ch-bourg.ght01.fr"
$To = "sylvain.saunier@ch-bourg.ght01.fr"
$Smtp = "smtp.ght01.fr"

.\PowerShell\PowerCLI\PS_PowerCLI_vCenter_Connexion-Infos.ps1
#Connect-VIServer $ESXserver -User $ESXUser -Password $ESXPwd
 
$VMArray = Get-VM
foreach ($VM in $VMArray) {
    $VMPoweredOn = $VM.PowerState
    $toolsStatus = $VM.ExtensionData.Guest.ToolsStatus
    if ($toolsStatus -ne "toolsOK" -and $VMPoweredOn -eq "PoweredOn") {
        $MailString_VMTools = "Les vmtools sur la machine '$VM' remontent avec le statut inhabituel suivant : '$toolsStatus'.`r`n"
        $ContenuMail_VMTools += $MailString_VMTools
    }
}
Send-MailMessage -From $From -To $To -Subject "CHB - VIRT - VM - VMTools en statut anormal" -SmtpServer $Smtp -Body $ContenuMail_VMTools