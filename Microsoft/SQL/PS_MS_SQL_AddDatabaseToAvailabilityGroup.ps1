$AGName   = "AG_Sage"
$Database = "DB01"

#    $tSQL = "
#    CREATE DATABASE [$Database];
#    "
#    Write-Host $tSQL 
#    Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-01"
    
    
    # Dummy backup to fake the controls for adding a DB into an AG
    # Do not run on a production environment !
    $tSQL = "
    BACKUP DATABASE [$Database] TO DISK = 'NUL';
    "
    Write-Host $tSQL 
    Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-01"
    
    
    $tSQL = "
    ALTER AVAILABILITY GROUP [$AGName]
    ADD DATABASE [$Database];
    "
    Write-Host $tSQL 
    Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-01"