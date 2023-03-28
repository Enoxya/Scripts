PROCESS #This is where the script executes 
{ 
    $path = "C:\users\saunies\Desktop" 

    $SearchLoc = "DC=groupe-bernard,DC=lan"
     
    $reportdate = Get-Date -Format ssddmmyyyy 
 
    $csvreportfile = $path + "\ALLADUsers_$reportdate.csv" 
     
    #import the ActiveDirectory Module 
    Import-Module ActiveDirectory 
     
    #Perform AD search. The quotes "" used in $SearchLoc is essential 
    #Without it, Export-ADUsers returuned error 
                  Get-ADUser  -searchbase "$SearchLoc" -Properties * -Filter * |  
                  Select-Object @{Label = "CanonName";Expression = {$_.CanonicalName}},
                  @{Label = "First Name";Expression = {$_.GivenName}},  
                  @{Label = "Nom de famille";Expression = {$_.Surname}}, 
                  @{Label = "Nom affiché";Expression = {$_.DisplayName}}, 
                  @{Label = "Nom de connexion";Expression = {$_.sAMAccountName}}, 
                 #@{Label = "Adresse complète";Expression = {$_.StreetAddress}}, 
                  @{Label = "Ville";Expression = {$_.City}}, 
                  @{Label = "État";Expression = {$_.st}}, 
                  @{Label = "Code postal";Expression = {$_.PostalCode}}, 
                  @{Label = "Pays/Région";Expression = {if (($_.Country -eq 'FR')  ) {'France'} Else {''}}}, 
                  @{Label = "Poste";Expression = {$_.Title}}, 
                  @{Label = "Entreprise";Expression = {$_.Company}}, 
                  @{Label = "Description";Expression = {$_.Description}}, 
                  @{Label = "Department";Expression = {$_.Department}}, 
                  @{Label = "Bureau";Expression = {$_.OfficeName}}, 
                  @{Label = "Téléphone";Expression = {$_.telephoneNumber}}, 
                  @{Label = "Email";Expression = {$_.Mail}}, 
                 #@{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -Properties DisplayName).DisplayName}}}, 
                  @{Label = "Statut du compte";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled 
                  @{Label = "Dernière connexion";Expression = {$_.lastlogondate}} | 
                   
                  #Export CSV report 
                  Export-Csv -Path $csvreportfile -NoTypeInformation     
}