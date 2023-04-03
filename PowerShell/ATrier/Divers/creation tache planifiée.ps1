# Création de la tâche planifiée 

$a = '"\\bsbpbodc2\perso\gadennj\Programmation\PowerShell\Opérationnels\NettoyageTrucks.ps1"'

	# Constantes de la tâche planifée
	$ComputerName = "SRV-NOR-INFRA"
    $RunAsUser = "BERNARD\SS"
	$userPwd = '"pui100"'
	$TaskName = "'Nettoyage Fichiers Trucks'"
	$TaskRun = "'Powershell.exe -noprofile -file $a'"
	$Schedule = "Daily"
	#$Days = '"MON,TUE,WED,THU,FRI"'
	$StartTime = "07:00"
	$execLevel = "HIGHEST"
    
 
	Write-Host "`n- Création de la tâche planifiée ""Création tache planifiée"" sur $ComputerName" -ForegroundColor Cyan
	$Command = "schtasks.exe /create /S $ComputerName /RU $RunAsUser /RP $userPwd /TN $TaskName /TR $TaskRun /SC $Schedule /ST $StartTime /RL $execLevel /F"
	Invoke-Expression $Command
	Clear-Variable Command -ErrorAction SilentlyContinue

