#On liste les espaces de non non "Standalone"
Get-DfsnRoot -ComputerName CHB-DFS | Where type -NotMatch "Standalone"

<#
Path                              Type      Properties                              TimeToLiveSec State  Description
----                              ----      ----------                              ------------- -----  -----------
\\chb.ts1.local\client            Domain V2 Site Costing                            300           Online            
\\chb.ts1.local\Fichiers          Domain V2 {Site Costing, AccessBased Enumeration} 300           Online            
\\chb.ts1.local\Fichiers_Medicaux Domain V2 Site Costing                            300           Online            
\\chb.ts1.local\TEST              Domain V2 Site Costing                            300           Online
#>


#Pour chaque espace de nom retourné, on vérifie le nombre de serveurs d'espace de noms qui les hébergent :
(Get-DfsnRootTarget -Path "\\chb.ts1.local\client").Count
<#
2
#>

PS U:\> (Get-DfsnRootTarget -Path "\\chb.ts1.local\Fichiers").Count
<#
2
#>

PS U:\> (Get-DfsnRootTarget -Path "\\chb.ts1.local\Fichiers_Medicaux").Count
<#
2
#>

PS U:\> (Get-DfsnRootTarget -Path "\\chb.ts1.local\TEST").Count


#Onvérifie le serveur cible de chaque espace de nom :
<#
PS U:\> Get-DfsnRootTarget
applet de commande Get-DfsnRootTarget à la position 1 du pipeline de la commande
Fournissez des valeurs pour les paramètres suivants :
Path : \\chb.ts1.local\TEST

Path                 TargetPath                   State  ReferralPriorityClass ReferralPriorityRank
----                 ----------                   -----  --------------------- --------------------
\\chb.ts1.local\TEST \\CHB-DFS.chb.ts1.local\TEST Online sitecost-normal       0                   



PS U:\> Get-DfsnRootTarget \\chb.ts1.local\client

Path                   TargetPath                        State  ReferralPriorityClass ReferralPriorityRank
----                   ----------                        -----  --------------------- --------------------
\\chb.ts1.local\client \\CHB-DFS.chb.ts1.local\client    Online sitecost-normal       0                   
\\chb.ts1.local\client \\CHB-DFS-02.CHB.TS1.LOCAL\client Online sitecost-normal       0                   



PS U:\> Get-DfsnRootTarget \\chb.ts1.local\Fichiers

Path                     TargetPath                          State  ReferralPriorityClass ReferralPriorityRank
----                     ----------                          -----  --------------------- --------------------
\\chb.ts1.local\Fichiers \\CHB-DFS.chb.ts1.local\Fichiers    Online sitecost-normal       0                   
\\chb.ts1.local\Fichiers \\CHB-DFS-02.CHB.TS1.LOCAL\Fichiers Online sitecost-normal       0                   



PS U:\> Get-DfsnRootTarget \\chb.ts1.local\Fichiers_Medicaux

Path                              TargetPath                                   State  ReferralPriorityClass ReferralPriorityRank
----                              ----------                                   -----  --------------------- --------------------
\\chb.ts1.local\Fichiers_Medicaux \\CHB-DFS.chb.ts1.local\Fichiers_Medicaux    Online sitecost-normal       0                   
\\chb.ts1.local\Fichiers_Medicaux \\CHB-DFS-02.CHB.TS1.LOCAL\Fichiers_Medicaux Online sitecost-normal       0                   
#>

#On exporte les metadonnées de chaque espace de nom pour les modifier / les reimporter après
dfsutil.exe root export \\chb.ts1.local\Client C:\Users\chb_ssaunier\Desktop\Metadonnees\Client_Origine.txt # \\chb.ts1.local\Fichiers et \\chb.ts1.local\Fichiers_Medicaux

#On supprime la cible (espace de nom) de la racine cible DFS:
Remove-DfsnRootTarget -TargetPath \\CHB-DFS.chb.ts1.local\client # xxx\Fichiers, \\...\Fichiers_Mdicaux
#Puis on va le réimporter et y reimporter les métadonnées modifiées
#Enfin, il faudra de même supprimer / recréer avec TargetPath pointant sur le CHB-DFS-02 (pas besoin de reimporter les métadonnées)


#On vérifie qu'est activé ou on active le comportement de référence racine du nom de domaine complet :
Get-DfsnServerConfiguration -ComputerName CHB-DFS.chb.ts1.local | Select UseFqdn
Get-DfsnServerConfiguration -ComputerName CHB-DFS-02.chb.ts1.local | Select UseFqdn

Set-DfsnServerConfiguration -ComputerName CHB-DFS.chb.ts1.local -UseFqdn $true
Set-DfsnServerConfiguration -ComputerName CHB-DFS-02.chb.ts1.local -UseFqdn $true


#On stop / start le service DFS (du coup a faire sur chaque serveur l'un après l'autre !)
Stop-servicedfs; start-service dfs

#On recréé / restaure / reajoute une cible à chaque espace de nom :
New-DfsnRootTarget -Target \\chb-dfs.chb.ts1.local\client #et les autres et une fois tous fait + reimport des metadonnées, il faut faire de même avec CHB-DFS-02


#On re importe les métadonnées :
dfsutil.exe root import set C:\Users\chb_ssaunier\Desktop\Metadonnees\Client.txt \\chb.ts1.local\client #\\chb.ts1.local\Fichiers et \\chb.ts1.local\Fichiers_Medicaux

