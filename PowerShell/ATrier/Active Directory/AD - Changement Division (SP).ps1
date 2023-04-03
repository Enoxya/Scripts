################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Janvi 2017
# Copie la société > Division
################################################

# Ajustements manuels
   #Get-ADUser -properties  DisplayName, Company, Division | select DisplayName, Company, Division 
   #| Set-ADUser -division  "GarageModerne"
    
   #
   
   $Groups = Get-ADGroup -filter {(Name -like "$ BDES - ARNO*") } 
  

# Enumération des groupes et des membres

CLS
Foreach ($Group in $Groups) 
{ 
        Write-Host " Groupe : $($Group.Name) ------------ " 
        $Members = Get-ADGroupMember -Identity $Group

            Foreach ($Member in $Members) 
                    { if($Member.ObjectClass -eq "user") 
                      {
		                Get-ADUser -properties DisplayName, Company, Division -filter { SamAccountName -eq $Member.SamAccountName } | Set-ADUser -division  "ARNO"
                        Get-ADUser -properties DisplayName, Company, Division -filter { SamAccountName -eq $Member.SamAccountName } | select DisplayName, Company, Division 
                      }
                    }
        Write-Host "  " 
		 
	} 





