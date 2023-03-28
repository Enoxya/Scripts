#################################################
# Script - Récupération des droits de dossiers  #
# Nathan MAY - Novembre 2017                    #
#################################################

# Ecriture dans un fichier
$stream = new-object System.IO.StreamWriter("C:\Users\saunies\Desktop\srv-nor-sauv_serveurs_hertz_partage-Droits.txt")

# Liste des répertoires et sous répertoires de la cible 
$liste_repertoire = Get-ChildItem "\\srv-nor-sauv\serveurs\hertz\partage" -Recurse

# Pour chaque résultat on teste s'il s'agit d'un fichier ou d'un répertoire
foreach ($repertoire in $liste_repertoire)
{ 
    If ($repertoire.Attributes -eq "Directory")
    {
            $Global_acl = Get-Acl $repertoire.FullName # On récupère les droits d'accès complets de chaque répertoire
            $Stream.WriteLine($repertoire.FullName)    # On inscrit dans le fichier le chemin du répertoire en cours
            $Stream.WriteLine("------")                

            foreach ($droit in $Global_acl.Access)     # On récupère les droits un par un et on écrit dans le fichier cible
            {
                $chaine = ""
                $chaine += $droit.IdentityReference
                $chaine += " : "
                $chaine += $droit.FileSystemRights
                $Stream.WriteLine($chaine)
            }
            $Stream.WriteLine("______________________")
    }
}
$stream.Close()