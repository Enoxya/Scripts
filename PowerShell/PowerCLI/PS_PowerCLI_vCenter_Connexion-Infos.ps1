function vCenter_Connexion {
    #Connexion au vCenter
    If (!$vCenter) {$vCenter = Read-Host "`nEntrez le FQDN du vCenter ou son IP"} #Si on en veut pas mettre le nom du vCenter dans les variables
    Try {
        Connect-VIServer -server $vCenter -EA Stop | Out-Null
    } Catch {
        "`r`n`r`nImpossible de se connecter au vCenter $vCenter" >> $log_Fichier_Chemin
        "Fin du programme...`r`n`r`n" >> $log_Fichier_Chemin
        Exit
    }
}

vCenter_Connexion
$global:DefaultVIServers | Select-Object Name, Version, Build