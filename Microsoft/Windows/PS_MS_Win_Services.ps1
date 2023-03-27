#Afficher état d'un service
Get-Service | Where {$_.Name -like "lan*"}

<# =>
Status   Name               DisplayName
------   ----               -----------
Running  LanmanServer       Serveur
Running  LanmanWorkstation  Station de travail
#>

#############################################################################################################################################################################################################################################################
#Voir pourquoi un service ne démarre pas
try {
    Start-Service dfs -ErrorAction Stop
} catch {
    # Examine and play with one of the following objects
    Write-Host "$($error[0].Exception)"
    Write-Host "$($_.exception)"
}

<# =>
Microsoft.PowerShell.Commands.ServiceCommandException: Le service « Espace de noms DFS (dfs) » ne peut pas démarrer en raison de l'erreur suivante : Impossible de démarrer le service dfs sur l'ordinateur '.'. ---> System.InvalidOperationException: Impossible de démarrer le service dfs sur l'ordinateur '.'. ---> System.ComponentModel.Win32Exception: Le service ou le groupe de dépendance n’a pas pu démarrer
   --- Fin de la trace de la pile d'exception interne ---
   à System.ServiceProcess.ServiceController.Start(String[] args)
   à Microsoft.PowerShell.Commands.ServiceOperationBaseCommand.DoStartService(ServiceController serviceController)
   --- Fin de la trace de la pile d'exception interne ---
Microsoft.PowerShell.Commands.ServiceCommandException: Le service « Espace de noms DFS (dfs) » ne peut pas démarrer en raison de l'erreur suivante : Impossible de démarrer le service dfs sur l'ordinateur '.'. ---> System.InvalidOperationException: Impossible de démarrer le service dfs sur l'ordinateur '.'. ---> System.ComponentModel.Win32Exception: Le service ou le groupe de dépendance n’a pas pu démarrer
   --- Fin de la trace de la pile d'exception interne ---
   à System.ServiceProcess.ServiceController.Start(String[] args)
   à Microsoft.PowerShell.Commands.ServiceOperationBaseCommand.DoStartService(ServiceController serviceController)
   --- Fin de la trace de la pile d'exception interne ---
#>


#############################################################################################################################################################################################################################################################
#Voir les dépendances d'un service
Get-Service -CN . | Where-Object { $_.Name -like "dfs"} | ForEach-Object {
    write-host -ForegroundColor 9 "Service name $($_.name)"
    if($_.DependentServices) { 
        write-host -ForegroundColor 3 "`tServices that depend on $($_.name)"
        foreach($s in $_.DependentServices) {
            "`t`t" + $s.name
        }
    } #end if DependentServices
    if($_.RequiredServices) { 
        Write-host -ForegroundColor 10 "`tServices required by $($_.name)"
        foreach($r in $_.RequiredServices) {
            "`t`t" + $r.name
        }
    } #end if DependentServices
} #end foreach-object

<# =>
Service name Dfs
        Services required by Dfs
                Mup
                RemoteRegistry
                SamSS
                LanmanWorkstation
                LanmanServer
                DfsDriver
#>
#############################################################################################################################################################################################################################################################