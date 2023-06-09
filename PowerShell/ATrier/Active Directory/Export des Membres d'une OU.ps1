
# -----------------------------------------------
# EXTRACTION GROUPES AD
# Jérémie GADENNE - 12/08/2015
# -----------------------------------------------

# Localisation du fichier d'export

Param ([Parameter(Mandatory=$true)]
   [string]$LogFilePath
)


$LogTime = Get-Date -Format "yyyyMMdd_hhmmss"
$LogFileName = "Export des users AD "
$LogFile = $LogFilePath + $LogFileName + $LogTime + ".csv"


# Recherche sur OU spécifiées

Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase "OU=CDPR,OU=PEUGEOT,OU=GROUPE BERNARD,DC=groupe-bernard,DC=lan" -Properties * | Sort-Object name  | Export-Csv $LogFile -NoType




