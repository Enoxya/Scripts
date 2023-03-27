$weekEnd = [System.DayOfweek]::Saturday, [System.DayOfweek]::Sunday

$dateDepart = (Get-Date).AddDays(-7)
$dateDuJour = (Get-Date)
$nbreJoursOuvres = 0

#Pour vérifier
#write-host "Date de départ : $dateDepart"
#write-host "Date du jour : $dateDuJour"

#Attention : -le compte le jour du lancement du script donc mettre -lt si on ne veut pas le compter !
while ($dateDepart -le $dateDuJour) {
    if ($dateDepart.DayOfweek -notin $weekEnd ) {
        $nbreJoursOuvres++
    }
    $dateDepart = $dateDepart.AddDays(1)
    
}
write-host "Il y a "$nbreJoursOuvres" jours ouvrés entre le "$dateDepart" et le "$dateDuJour