$WeekEnd = [System.DayOfweek]::Saturday, [System.DayOfweek]::Sunday

#$dateDepart = (Get-Date).AddDays(-7)
$dateDebut = Get-Date(Read-Host "Entrer la date de départ (sous la forme JJ/MM/AAAA)")
$dateDepart = $dateDebut
#$dateDuJour = (Get-Date)
$dateFin = Get-Date(Read-Host "Entrer la date de fin (sous la forme JJ/MM/AAAA)")
$nbreJoursOuvres = 0

#Pour vérifier
#write-host "Date de départ : $dateDebut"
#write-host "Date du jour : $dateFin"


#Attention : -le compte le jour du lancement du script donc mettre -lt si on ne veut pas le compter !
if ($dateDebut -le $dateFin) {
    while ($dateDebut -le $dateFin) {
        if ($dateDebut.DayOfweek -notin $WeekEnd ) {
            $nbreJoursOuvres++
        }
    $dateDebut = $dateDebut.AddDays(1) 
    }
write-host "Il y a $nbreJoursOuvres jours ouvrés entre le $($dateDepart.ToString('dd/MM/yyyy')) et le $($dateFin.ToString('dd/MM/yyyy'))"
}
else {
    Write-Host "Arrete tes conneries Jean-Jacques !"
    Write-Host "La date de départ ne peut pas être postérieure à la date de fin..."
}