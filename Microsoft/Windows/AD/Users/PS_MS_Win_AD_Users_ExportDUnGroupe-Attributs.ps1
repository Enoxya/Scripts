$nomGroupeAD = "l_portail_patients_backoffice" # Pour tester : G_Accueil_administratif
$cheminExport = "C:\temp\exportDuGroupe_"+$nomGroupeAD+"_$((get-date).tostring('dd-MM-yyyy')).csv"

get-adgroupmember $nomGroupeAD | `
get-aduser -properties objectGUID,sAMAccountName,sn,givenname,displayname,mail,employeeNumber | Where { $_.Enabled -eq $True} |`
foreach {
    new-object psobject -Property @{
        uid = $_.objectGUID # Correspondance AD
        login = $_.sAMAccountName # Le login de l’intervenant
        nom = $_.sn # Le nom de l'intervenant
        prenom = $_.givenname # Le prenom de l'intervenant)
        nomComplet = $_.displayname # Le nom complet de l’intervenant (utilisé po
        #titre = $_. # Le titre de l’intervenant
        emailPrincipal = $_.mail # L'email de l'intervenant
        matricule = $_.employeeNumber # Le numéro de matricule de l’intervenant
        #CentreResponsabiliteDefaut = $_. # Le centre de responsabilité par défaut de l’intervenant
        #UfDefaut = $_. # L’unité fonctionnelle par défaut de l’intervenant
        #Sexe = $_. # Le sexe de l’intervenant
        #Qualite = $_. # La qualité de l’intervenant (Monsieur, Madame)
        #rpps = $_. # Le numéro de RPPS de l’intervenant
        #ancienID  = $_. # L’ancien ID CristalNet de l’intervenant
        }
} | Select uid, login, nom, prenom, nomComplet, titre, emailPrincipal, matricule, CentreResponsabiliteDefaut, ufDefaut, Sexe, Qualite, rpps, ancienID | `
Export-Csv -delimiter ";" -path $cheminExport -Encoding UTF8 -NoTypeInformation
  