# Cr�ation de la t�che planifi�e 

$a = '"\\bsbpbodc2\perso\gadennj\Programmation\PowerShell\Op�rationnels\NettoyageTrucks.ps1"'

	# Constantes de la t�che planif�e
	$ComputerName = "SRV-NOR-INFRA"
    $RunAsUser = "BERNARD\SS"
	$userPwd = '"pui100"'
	$TaskName = "'Nettoyage Fichiers Trucks'"
	$TaskRun = "'Powershell.exe -noprofile -file $a'"
	$Schedule = "Daily"
	#$Days = '"MON,TUE,WED,THU,FRI"'
	$StartTime = "07:00"
	$execLevel = "HIGHEST"
    
 
	Write-Host "`n- Cr�ation de la t�che planifi�e ""Cr�ation tache planifi�e"" sur $ComputerName" -ForegroundColor Cyan
	$Command = "schtasks.exe /create /S $ComputerName /RU $RunAsUser /RP $userPwd /TN $TaskName /TR $TaskRun /SC $Schedule /ST $StartTime /RL $execLevel /F"
	Invoke-Expression $Command
	Clear-Variable Command -ErrorAction SilentlyContinue

