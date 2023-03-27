$mois = Get-Date -Format 'MMMM_yyyy'
$Mois = (Get-Culture).textinfo.totitlecase($mois)
$NomRapport = "Exchange_Rapport_"+$mois+".html"

.\Get-ExchangeEnvironmentReport.ps1 -HTMLReport $NomRapport -SendMail -ViewEntireForest $true -MailFrom exchange@ght01.fr -MailTo ssaunier@ch-bourg01.fr -MailServer mercure.chb.ts1.local