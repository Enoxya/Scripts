# --------------------------------------------------------------
# Script copie archives mails LLD
# Jérémie GADENNE - Février 2017
# --------------------------------------------------------------


# Définition des variables
$slavePC = @("BSBPVIDESC", "BSBPVIGIRA")
$sharePC = @('\\BSBPVIDESC\Archives', '\\BSBPVIGIRA\Archives')
$source = 'C:\Archives\Archive3.pst'
$logFile = "C:\Archives\Log.txt"

Write-Host "Lancement du programme de copie d'archives LLD"

# 1. Initialiser le fichier de LOG
$date = Get-Date -format D
$heure = Get-Date -format t
Add-content $logFile "------------------------------------------------------------"
Add-content $logFile "Journalisation LLD du $date - Début à $heure" 

# 2. Stopper le processus "Outlook" local sur le PC MASTER : 
Try { Get-Process Outlook -ErrorAction Stop | Stop-Process
      Add-content $logFile "Réussite fermeture OUTLOOK sur PC MASTER "
    } 
Catch { Add-content $logFile "Echec fermeture OUTLOOK sur PC MASTER " } 


# 3. Fermer Outlook sur les deux PC distants SLAVE
Read-Host "Mot de passe ?" -AsSecureString | ConvertFrom-SecureString | Out-File C:\Archives\hash.pass
$hash = Get-Content "C:\Archives\hash.pass" | ConvertTo-SecureString 
$token = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "BERNARD\admpo", $hash
Foreach ($PC in $slavePC) {
                            Try { Invoke-Command -ScriptBlock { Get-Process Outlook | Stop-Process -Force } -computerName $PC -Credential $token -errorAction Stop
                                    Add-content $logFile "Réussite fermeture OUTLOOK sur PC : $PC "
                                } 
                            Catch { Add-content $logFile "Echec fermeture OUTLOOK sur PC : $PC " } 
                          }

# 4. Attendre que les process soient bien fermés
Start-Sleep -Second 30

# Copier les fichiers
Write-host "Copie des fichiers en cours..."
foreach ($share in $sharePC) {
          Try { Copy-Item -Path $source -Destination $share -Force
                Add-content $logFile "Copie sur $share réussie"
              } 
          Catch { Add-content $logFile "Copie sur $share échec " } 
}

# 5.Eteindre les PC 
Foreach ($PC in $slavePC) { 
Stop-Computer -ComputerName $PC -Force 
Write-Host "Extinction du PC : $PC" 
Add-content $logFile "Extinction PC : $PC " 
}

$heure = get-date -format t
Add-content $logFile "Fin du process à $heure"

# 6. Extinction du PC local
$win32OS = Get-wmiobject win32_operatingsystem -EnableAllPrivileges
$win32OS.win32shutdown(8)
