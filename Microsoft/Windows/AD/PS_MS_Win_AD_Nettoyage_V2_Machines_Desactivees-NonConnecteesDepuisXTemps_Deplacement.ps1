#------------------------------------------------------------------------------------
#
# Ce script déplace les comptes AD machine non connectés depuis plus de XX jours/mois
# et les comptes AD machine désactivés
# dans une OU à définir
#
# -----------------------------------------------------------------------------------

#Paramètres :
$domaine = "DC=ideha, DC=int"
$nbreJoursInactivite = 90
$OUCible = "OU=PC-Desactives, OU=PC, DC=IDEHA, DC=INT"
$serveurSMTP = "idedomino.ideha.int"
$expediteur = "<postmaster@ideha.fr>"
$destinataire = "<exploit@acg-synergies.fr>"
$sujetMail = "IDEHA - Active Directory - Comptes AD désactivées et inactifs depuis plus de $nbreJoursInactivite jours - Déplacés"

$listeMachinesInactivesDepuisXTemps = Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan $nbreJoursInactivite$listeMachinesDesactivees = Search-ADAccount -ComputersOnly -AccountDisabled$listeMachines = ($listeMachinesInactivesDepuisXTemps + $listeMachinesDesactivees) | Sort-Object -Unique     
$corpsMail = "Bonjour, `n`n" `+ "Les machines suivantes ont été déplacées dans l'OU `"$OUCible`" à cause d'une inactivité de plus de 90 jours `n" `+ "Sans contre indication de votre part, elles seront définitivement supprimées dans une semaine : `n`n"

foreach ($machine in $listeMachines) {
    $corpsMail = $corpsMail + $machine.Name + "`r`n"
    Move-ADObject -Identity $machine.DistinguishedName -TargetPath $OUCible
    }

$encoding=[System.Text.Encoding]::UTF8
Send-MailMessage -To $destinataire -From $expediteur -Subject $sujetMail -Body $corpsMail -SmtpServer $serveurSMTP -Encoding $encoding


Clear-Variable -Name domaine
Clear-Variable -Name nbreJoursInactivite
Clear-Variable -Name OUCible
Clear-Variable -Name serveurSMTP
Clear-Variable -Name expediteur
Clear-Variable -Name destinataire
Clear-Variable -Name sujetMail
Clear-Variable -Name listeMachinesInactivesDepuisXTemps
Clear-Variable -Name listeMachinesDesactivees
Clear-Variable -Name listeMachines
Clear-Variable -Name machine
Clear-Variable -Name corpsMail
Clear-Variable -Name encoding

exit
