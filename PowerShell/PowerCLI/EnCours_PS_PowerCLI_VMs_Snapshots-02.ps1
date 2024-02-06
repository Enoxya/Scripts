<#
Scanner les VM présentes sur l’ESX ou le vCenter et d’envoyer un courriel si un snapshot est plus ancien qu’un certain nombre de jours.
Par défaut, si un snapshot existe sur une machine virtuelle, un mail est tout de même envoyé.
#>

$From = "admin-vmw@localhost"
$To = "supervision@localhost"
$Smtp = "smtp.localdomain"
$Delay = 7
 
Connect-VIServer $ESXserver -User $ESXUser -Password $ESXPwd
 
$VMNamesArray = Get-VM | select Name
foreach ($VMName in $VMNamesArray)
    {
    $VMSnaps = Get-Snapshot $VMName.name
    foreach ($Snap in $VMSnaps)
        {
        $now = Get-Date
        if ($Snap.Created.AddDays($Delay) -gt $now -eq $false)
            {
            $SnapVM = $Snap.VM
            $MailString = "Bonjour, le snapshot '$Snap' de la machine '$SnapVM' existe depuis plus de $Delay jours."
            Send-MailMessage -From $From -To $To -Subject "Alerte snapshot" -SmtpServer $Smtp -Body $MailString
            }
        else
            {
            $MailString = "Aucun snapshot datant de plus de $Delay jours existant."
            Send-MailMessage -From $From -To $To -Subject "Rapport snapshot" -SmtpServer $Smtp -Body $MailString
            }
        }
    }