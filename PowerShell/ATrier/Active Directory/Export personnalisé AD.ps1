     
    #import the ActiveDirectory Module 
    Import-Module ActiveDirectory 
    
    # Construction du fichier LOG
    $LogFilePath = "C:\users\mayn\"
    $LogFileName = "Export AD TOTAL"
    $Customize= " 30 nov"
    $LogFile = $LogFilePath + $LogFileName + $Customize + ".csv"
    
    
    # Filtrer selon la fonction
    #$filtre = {(Name -like 'Direct*') -or (Title -like 'Ass*') }
    $filter = {name -like '*' }
    #$filtre = {Company -like 'BP'}
    # Pour faire un export vers un CSV uniquement
    Get-ADUser -properties * -filter $filter | Select DisplayName,sAMAccountName, Company, City, Department, Title, Manager, @{n="Mail";e={$_.EmailAddress.ToLower()}} |  export-csv C:\users\mayn\EXPORT-AD-MAIL2.csv -NoTypeInformation 

    # Pour récupérer les objets et appliquer des méthodes dessus :
    # $result = Get-ADUser -properties * -filter $filter | Set-ADUser -Company $null
    

   