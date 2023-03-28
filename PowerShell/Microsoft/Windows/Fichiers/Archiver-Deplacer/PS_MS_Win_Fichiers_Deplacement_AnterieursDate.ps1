#Variables
$cheminSource = "C:\inetpub\wwwroot\PortailCDPR\documents"
$cheminDestination_Racine = "D:\Archives"
$dateLimite = (Get-Date).Adddays(-478)

#Déplacement des fichiers
Write-Progress -Activity "Récupération de la liste des fichiers en cours..." -Status "Veuillez patienter"
$listeFichiersADeplacer = Get-ChildItem -Path $cheminSource -Recurse -Force `    | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $dateLimite } `    | ForEach-Object -Process {$_.FullName}

ForEach ($fichier in $listeFichiersADeplacer) {
    #Récupération du chemin du dossier contenant le fichier
    $cheminDestination_Modifie = $fichier.replace('C:',$cheminDestination_Racine)
    $cheminDestination_RepertoireParent = Split-Path -Path $cheminDestination_Modifie

    #Vérification existance répertoire de destination, et création si c'est OK
    if(!(Test-Path $cheminDestination_RepertoireParent)) {
        #Le répertoire de destination n'existe pas, on le créé et on déplace le fichier dedans
        $dossier = New-Item -ItemType directory -Path $cheminDestination_RepertoireParent
        Move-Item $fichier $dossier
        }
    else {
        #Le répertoire de destination existe déjà, on déplace le fichier dedans
        Move-Item $fichier $cheminDestination_RepertoireParent
        }
 }

