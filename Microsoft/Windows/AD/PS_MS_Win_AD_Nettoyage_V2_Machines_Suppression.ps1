#------------------------------------------------------------------------------------
#
# Ce script désactive (si pas désactivés) les comptes AD machine non connectés depuis plus de XX jours/mois
# et les comptes AD machine désactivés
# dans une OU à définir
#
# -----------------------------------------------------------------------------------

#Paramètres :
$domaine = "DC=ideha, DC=int"
$OUSource = "OU=Test-Supp, OU=PC-Desactives, OU=PC, DC=IDEHA, DC=INT"
$serveurSMTP = "idedomino.ideha.int"
$expediteur = "<postmaster@ideha.fr>"
$destinataire = "<exploit@acg-synergies.fr>"
$sujetMail = "IDEHA - Active Directory - Comptes AD désactivées et inactifs - Supprimés"

$listeMachines_ADesactiver = Get-ADComputer -Filter {Enabled -eq $true} -Properties CN -SearchBase $OUSourceforeach ($machine in $listeMachines_ADesactiver) {
    Disable-ADAccount -Identity $machine.DistinguishedName}$listeMachines_ASupprimer = Get-ADComputer -Filter * -Properties CN -SearchBase $OUSource

$corpsMail = "Bonjour, `n`n" `+ "Les machines suivantes se trouvaient dans l'OU `"$OUCible`" et ont été supprimées : `n`n"

foreach ($machine in $listeMachines_ASupprimer) {
    $corpsMail = $corpsMail + $machine.Name + "`r`n"
    Remove-ADComputer -Identity $machine.DistinguishedName
 }

$encoding=[System.Text.Encoding]::UTF8
Send-MailMessage -To $destinataire -From $expediteur -Subject $sujetMail -Body $corpsMail -SmtpServer $serveurSMTP -Encoding $encoding


Clear-Variable -Name domaine
Clear-Variable -Name OUSource
Clear-Variable -Name serveurSMTP
Clear-Variable -Name expediteur
Clear-Variable -Name destinataire
Clear-Variable -Name sujetMail
Clear-Variable -Name listeMachines_ADesactiver
Clear-Variable -Name listeMachines_ASupprimer
Clear-Variable -Name machine
Clear-Variable -Name corpsMail
Clear-Variable -Name encoding