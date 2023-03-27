$vCenter_Nom ##le nom d'hôte ou IP du VCENTER
$datastoreDestination_Nom ##Variable pour le Datastore de destination de l'ensemble des futurs VMs
$HotesCluster_Nbre ##Nombre d'hote ESX dans le cluster
$modele_Nom ##Le modèle de base (template obligatoire)
$poolVMs_Nom ##Nom du pool de ressource, pas obligatoire, vous pouvez supprimer si jamais
$fichierPersonnalisation_Nom ##Fichier de personnalisation créé depuis le vcenter (vous savez le fameux "Gestionnaire de spécification de personnalisation"
$VMs_Nom ##Nom des futurs VM, le {0} corresponds au numéro, exemple "maison{0}" va créer maison1, maison2 etc...

Clear
Add-PSSnapIn VMware.VimAutomation.Core  #powercli
####### VARIABLES #######
$vCenter_Nom = Read-Host -Prompt "Nom / IP du vCenter :"                                                           ##Prompt pour le nom d'hôte ou IP du VCENTER
$login = Read-Host -Prompt "Login :"                                                                               ##Prompt pour l'utilisateur
$password = Read-Host -Prompt "Mot de passe :"                                                                     ##Prompt pour le mot de passe
$datastoreDestination_Nom = Read-Host -Prompt "Datastore de destination :"                                         ##Prompt pour le Datastore de destination de l'ensemble des futures VMs
$HotesCluster_Nbre = Read-Host -Prompt "Nbre d'hotes ESX dans le cluster :"                                        ##Prompt pour le nombre d'hote(s) ESX dans le cluster
$modele_Nom = Read-Host -Prompt "Nom du modèle (template) :"                                                       ##Prompt pour le nom du modèle de base (template)
$VMs_Nombre = Read-Host -Prompt "Nombre de VM à créer :"                                                           ##Prompt pour le nombre de VM à créer
$poolVMs_Nom = Read-Host -Prompt "Nom du pool de ressources :"                                                     ##Nom du pool de ressource, pas obligatoire, vous pouvez supprimer si jamais
$fichierPersonnalisation_Nom = Read-Host -Prompt "Nom du fichier de personnalisation :"                            ##Fichier de personnalisation créé depuis le vcenter
$VMs_Nom = Read-Host -Prompt "Nom des futures VMs (Exemple : VDI-TEST-{0} va créer VM-TEST-1, VM-TEST-2, etc.) :"  ##Nom des futurs VM, le {0} corresponds au numéro, exemple "maison{0}" va créer maison1, maison2 etc...  
###### FIN DES VARIABLES #######

Connect-VIServer -Server $vCenter_Nom -User $login -Password $password
$spec = Get-OSCustomizationSpec -Name $fichierPersonnalisation_Nom

function creation {
    1..$VMs_Nombre | foreach{
        $VM_Nom = $VMs_Nom -f $_
        $VM = Get-VM -Name $VM_Nom
            if ($vm) {
                "{0} exists" -f $VM_Nom
                Write-Host "Machines existent déjà" -ForegroundColor Red
                exit
                Disconnect-VIServer -Confirm:$false
                     }
            else {
                $Hote_Numero = get-random -Maximum $HotesCluster_Nbre         ##genere un nombre         
                $ESX = (Get-VMHost)[$Hote_Numero]                    ##selectionnne un hote en fonction du nombre au dessus
                $ESX | New-VM -Name $VM_Nom -Template $modele_Nom -Datastore $datastoreDestination_Nom -OSCustomizationSpec $spec -ResourcePool $poolVMs_Nom -RunASync
                 }
}
}
Clear
function log {
              Do {
              Clear
              Get-Task | Where-Object { $_.name -eq "CloneVM_Task" -and $_.State -eq "Running"} | Format-Table
              sleep 10
              Clear
}
              until ((Get-Task | Where-Object { $_.name -eq "CloneVM_Task" -and $_.State -eq "Running"}) -eq $Null)}

function StartdesVM {
    1..$VMs_Nombre | foreach{
                          $VM_Nom = $VMs_Nom -f $_ 
                          Start-VM -VM $VM_Nom
                          sleep 3
                          }
}

creation #fonction de creation des VM
log #fonction de log interractif
StartdesVM #demarrage des VM

Write-Host "Machines virtuelles crées et démarrées, merci de patienter le temps que le profil de VM s'applique !" -ForegroundColor Yellow
Disconnect-VIServer -Confirm:$false