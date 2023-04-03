################################################
# SCript Recherche des comptes mals renseignés
# Jérémie GADENNE - Mars 2017
# 
################################################

$LogFileName = "Export AD - Global "
$LogFilePath = "C:\"
$LogFile = $LogFilePath + $LogFileName + ".txt"

# Ajustements manuels

$societes = get-aduser -properties company  -Filter {company -like "*" } | Group company | Select-Object name

     

#$users | select Name, Office, TelephoneNumber, Title, Department, Company, StreetAddress, PostalCode, State, City | ft

    Foreach ($soc in $val.name) { 
    
        $users = Get-ADUser -properties * -Filter {company -eq $soc}

        Write-Output "Société : $soc ------------ " | Out-File $LogFile -Append
                                             
                    Write-Output $users | select Name, Office, TelephoneNumber, Title, Department | ft | Out-File $LogFile -Append
            
        
	}



    
# Recherche dans une OU

Get-ADUser -SearchBase "OU=RH,OU=Listes Exploitation,OU=Distribution,OU=GROUPES,OU=NEW BERNARD,DC=groupe-bernard,DC=lan" -Properties * -Filter {samAccountName -like "*"} | sort WhenCreated | select name, samaccountname, WhenCreated | ft | Out-File C:\Ref.txt
    
    # Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq "abitboa"} | Set-ADUser -Manager giallar


    #Get-ADUSer -properties  DisplayName, Manager -Filter "*" | where { $_.Manager -EQ "CN=BUENADICHA  Gregory,OU=PGlaravoire,OU=PEUGEOT,OU=GROUPE BERNARD,DC=groupe-bernard,DC=lan"} | Set-ADUser -Manager $null