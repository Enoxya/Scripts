
# -----------------------------------------------
# EXTRACTION GROUPES AD
# Jérémie GADENNE - 12/08/2017
# -----------------------------------------------

# Localisation du fichier d'export


Import-module activedirectory  

#Param ([Parameter(Mandatory=$true)]   [string]$LogFilePath)

$LogTime = Get-Date -Format "yyyyMMdd_hhmmss"
$LogFileName = "Export des groupes AD au "
$LogFilePath = "C:\Users\gadennj\Desktop"
$LogFile = $LogFilePath + $LogFileName + $LogTime + ".txt"


# Filtrage sur les groupes désirés

$Groups = Get-ADGroup -filter {(Name -like "INFOCENTRE*") } #  | export-csv C:\Users\gadennj\Desktop\GroupListBO1.txt -NoTypeInformation
  #-and (GroupCategory -eq "Distribution")

# Enumération des groupes et des membres

Foreach ($Group in $Groups) { Write-Output "Groupe : $($Group.Name)" 

    $Members = Get-ADGroupMember -Identity $Group
    Write-Output " Groupe : $($Group.Name) ------------ " | Out-File $LogFile -Append

       Foreach($Member in $Members) {
        
        if($Member.ObjectClass -eq "user") {
		        
            $user = Get-ADUser $Member -Properties *
            Write-Output "- $($user.Name)" | Out-File $LogFile -Append
            Write-Host "- $($user.Name)"
            }
        }
		 Write-Output "      " | Out-File $LogFile -Append
	} 


#Get-ADUser -Identity USERNAME -Properties *