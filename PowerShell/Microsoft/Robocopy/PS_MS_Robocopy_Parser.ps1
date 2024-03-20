# blog.enguerrand.pro
# Robocopy Log Parser - permet de récupérer les stats de transfert à partir de logs Robocopy

# La fonction parse est la fonction contenant le regex permettant d'extraire les nombres présents dans la ligne de texte passée en paramètre.
function parse {
    param($inputstr)
    $newstr = $inputstr -replace "[^0-9]" , '-' # On remplace tout ce qui n'est pas un entier par un tiret, permet de séparer chaque nombre correctement.
    $newstr -match '[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)' # On trap tous les caractères qui sont des chiffres .
    $stats = @($matches[1],$matches[2],$matches[3],$matches[4],$matches[5],$matches[6]) # La variable $matches contient les nombres qui ont été extraits de la ligne. Il y en a 6, un pour chaque colonne de stat Robocopy.
    return $stats # On renvoie le contenu de $stats pour qu'il soit ensuite traité par le script et stocké dans un objet pour export CSV.
}

$output=@() # Objet global qui sera exporté en CSV
$logfiles = Get-ChildItem "*.log" | Select-Object Name
foreach($logfile in $logfiles) {
    Write-Host "Parsing $($logfile.Name)"
    $logcontent = Get-Content $logfile.Name
    $strf = $logcontent[$logcontent.Count-5] # En partant de la fin, on récupère la cinquième ligne du log, c'est elle qui contient toujours le nombre de fichiers transférés.
    $strd = $logcontent[$logcontent.Count-6] # En partant de la fin, on récupère la sixième ligne du log, c'est elle qui contient toujours le nombre de répertoires transférés.
    $statf = parse($strf) # Appel de la fonction parse pour traiter les stats des fichiers.
    $statd = parse($strd) # Appel de la fonction parse pour traiter les stats des répertoires.
    $dump = New-Object PSCustomObject # Création de l'objet pour le fichier de log actuellement traité.
    # Ajout des statistiques comme membre de l'objet, on appelle donc à chaque fois la valeur contenue dans $statf ou $statd qui correspond à une statistique.
    $dump | Add-Member -Name "Filename" -Value $($logfile.Name) -MemberType NoteProperty
    $dump | Add-Member -Name "Files Total" -Value $statf[1] -MemberType NoteProperty
    $dump | Add-Member -Name "Files Copied" -Value $statf[2] -MemberType NoteProperty
    $dump | Add-Member -Name "Files Skipped" -Value $statf[3] -MemberType NoteProperty
    $dump | Add-Member -Name "Files Mismatched" -Value $statf[4] -MemberType NoteProperty
    $dump | Add-Member -Name "Files FAILED" -Value $statf[5] -MemberType NoteProperty
    $dump | Add-Member -Name "Files Extras" -Value $statf[6] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs Total" -Value $statd[1] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs Copied" -Value $statd[2] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs Skipped" -Value $statd[3] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs Mismatched" -Value $statd[4] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs FAILED" -Value $statd[5] -MemberType NoteProperty
    $dump | Add-Member -Name "Dirs Extras" -Value $statd[6] -MemberType NoteProperty
    $output+=$dump # On ajoute cet objet à l'objet global qui va contenir les stats de tous les fichiers de log.
}
$output | Export-Csv robocopy_logs_stats.csv -Delimiter ";" -Encoding utf8 # Export du fichier CSV final.