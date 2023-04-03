Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

function Show-Menu
{
     param (
           [string]$Title = 'Boites mails sur les bonnes BDD'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Choisissez '1' pour déplacer les  BAL dont le nom commence par A-B-C-D-E vers DATABASE_AE."
     Write-Host "2: Choisissez '2' pour déplacer les  BAL dont le nom commence par F-G-H-I-J vers DATABASE_FJ."
     Write-Host "3: Choisissez '3' pour déplacer les  BAL dont le nom commence par K-L-M-N-O vers DATABASE_KO."
     Write-Host "4: Choisissez '4' pour déplacer les  BAL dont le nom commence par P-Q-R-S-T vers DATABASE_PT."
     Write-Host "5: Choisissez '5' pour déplacer les  BAL dont le nom commence par U-V-W-X-Y-Z vers DATABASE_UZ."
     Write-Host "6: Choisissez '6' pour nettoyer les demandes de déplacements."
     Write-Host "Q: Choisissez 'Q' pour quitter le menu."
}

    
     Show-Menu
     $input = Read-Host "Sélectionnez une option"
     switch ($input)
            { 
            1 {
            
                cls
                'Déplacement des BAL dont le nom commence par A-B-C-D-E vers DATABASE_AE '
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_AE.txt"
                echo "Début du déplacement - DATABASE_AE " >> $fichier
                Get-date >> $fichier
                Get-Recipient -ResultSize Unlimited | Where {($_.LastName -like "A*")-or ($_.LastName -like "B*") -or ($_.LastName -like "C*") -or ($_.LastName -like "D*") -or ($_.LastName -like "E*")} `
                    | ForEach `
                        { if ($_.database -ne "DATABASE_AE") `
                                    {New-MoveRequest -Identity $_.DisplayName -TargetDatabase DATABASE_AE}}
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_AE.txt"
                echo "Fin du déplacement - DATABASE_AE" >> $fichier
                Get-date >> $fichier
           } 2 {
           
                cls
                'Déplacement des  BAL dont le nom commence par F-G-H-I-J vers DATABASE_FJ.'
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_FJ.txt"
                echo "Début du déplacement - DATABASE_FJ " >> $fichier
                Get-date >> $fichier
                Get-Recipient -ResultSize Unlimited | Where {($_.LastName -like "F*")-or ($_.LastName -like "G*") -or ($_.LastName -like "H*") -or ($_.LastName -like "I*") -or ($_.LastName -like "J*")} `
                         | ForEach `
                        { if ($_.database -ne "DATABASE_FJ") `
                                    {New-MoveRequest -Identity $_.DisplayName -TargetDatabase DATABASE_FJ}}
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_FJ.txt"
                echo "Fin du déplacement - DATABASE_FJ" >> $fichier
                Get-date >> $fichier

           } 3 {
           
                cls
                'Déplacement des  BAL dont le nom commence par K-L-M-N-O vers DATABASE_KO.'
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_KO.txt"
                echo "Début du déplacement - DATABASE_KO " >> $fichier
                Get-date >> $fichier
                Get-Recipient -ResultSize Unlimited |  Where {($_.LastName -like "K*")-or ($_.LastName -like "L*") -or ($_.LastName -like "M*") -or ($_.LastName -like "N*") -or ($_.LastName -like "O*")} `
                          | ForEach `
                        { if ($_.database -ne "DATABASE_KO") `
                                    {New-MoveRequest -Identity $_.DisplayName -TargetDatabase DATABASE_KO}}
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_KO.txt"
                echo "Fin du déplacement - DATABASE_KO" >> $fichier
                Get-date >> $fichier
           } 4 {
           
                cls
                'Déplacement des  BAL dont le nom commence par P-Q-R-S-T vers DATABASE_PT.'
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_PT.txt"
                echo "Début du déplacement - DATABASE_PT " >> $fichier
                Get-date >> $fichier
                Get-Recipient -ResultSize Unlimited | Where {($_.LastName -like "P*")-or ($_.LastName -like "Q*") -or ($_.LastName -like "R*") -or ($_.LastName -like "S*") -or ($_.LastName -like "T*")} `
                          | ForEach `
                        { if ($_.database -ne "DATABASE_PT") `
                                    {New-MoveRequest -Identity $_.DisplayName -TargetDatabase DATABASE_PT}}
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_PT.txt"
                echo "Fin du déplacement - DATABASE_PT" >> $fichier
                Get-date >> $fichier

           } 5 {
           
                cls
                'Déplacement des  BAL dont le nom commence par U-V-W-X-Y-Z vers DATABASE_UZ.'
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_UZ.txt"
                echo "Début du déplacement - DATABASE_UZ " >> $fichier
                Get-date >> $fichier
                Get-Recipient -ResultSize Unlimited | Where {($_.LastName -like "U*")-or ($_.LastName -like "V*") -or ($_.LastName -like "W*") -or ($_.LastName -like "X*") -or ($_.LastName -like "Y*") -or ($_.LastName -like "Z")} `
                    | ForEach `
                        { if ($_.database -ne "DATABASE_UZ") `
                                    {New-MoveRequest -Identity $_.DisplayName -TargetDatabase DATABASE_UZ}}
                $fichier =  "C:\Users\mayn\Desktop\LogDatabase_UZ.txt"
                echo "Fin du déplacement - DATABASE_UZ" >> $fichier
                Get-date >> $fichier

           } 6 {
           
                cls
                'Nettoyage des demande de nettoyage.'
                $fichier =  "C:\Users\mayn\Desktop\LogNettoyage.txt"
                echo "Début du nettoyage" >> $fichier
                Get-MoveRequest -MoveStatus completed | Remove-MoveRequest -Confirm:$false 
                $fichier =  "C:\Users\mayn\Desktop\LogNettoyage.txt"
                echo "Fin du nettoyage" >> $fichier
                Get-date >> $fichier
           } 
               
                      
            'q' {
             
                return ; break
           }
           default {
                Write-Host "L'option choisie est incorrecte."; Show-Menu
                }
           }
           
           





