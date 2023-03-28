# Script health check de l'environnement Citrix Groupe Bernard
# Contrôle des éléments suivants :
# 	Delivery Controller + StoreFront
# 	XenApp Servers
# 	File Server
# 	VUEM Server
# 	Citrix PVS Servers


Add-PSSnapin Citrix.Broker.Admin.V2

$LogPath = "C:\_admin\Scripts"
$LogFile = "XenApp-Results.txt"

New-Item -path $Logpath -Name $LogFile -ItemType file -force

$ListeXenAppRenault = Get-Content "C:\_admin\Scripts\ListeXenApp-Renault.txt"

function CheckService{

 param($ServiceName)
 $arrService = Get-Service -Name $ServiceName
 if ($arrService.Status -ne "Running"){ 
Add-Content -Path $LogFile -Value "Le service $ServiceName est arrêté sur le serveur $Server"
 
 }
 }

#Check Services status => Serveurs XenApp

foreach ($Server in $ListeXenAppRenault)
{

CheckService Spooler
CheckService BrokerAgent
CheckService cpsvc
CheckService ctxprofile

}

#Check Services status => Delivery Controller



#Check EventLog => Serveurs XenApp



#Check EventLog => Delivery Controller



#Check Write Cache size => Serveurs XenApp















