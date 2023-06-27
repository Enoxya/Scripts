# Action à exécuter - ScriptLLD.ps1
$action=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass ‪\\srv-nor-infra\Scripts\LLD\ScriptLLD.ps1"

# Planification de la tâche - Tous les jours à 19:00
$trigger=New-ScheduledTaskTrigger -Daily -At 19:00PM

# Enregistrement de la tâche et "Exécuter sous"
Register-ScheduledTask -TaskName "Script LLD" -Trigger $trigger -Action $action -User "Bernard\admpo" –Password t4d3p6

# Exécuter la tache 
Start-ScheduledTask "Script LLD"

# Arrêt de la tache 
Stop-ScheduledTask "Script LLD"
