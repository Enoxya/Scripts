  
 $AGName = "AG_Sage"
 
 $tSQL = "
  CREATE AVAILABILITY GROUP [$AGName]
  FOR REPLICA ON 
  'GB-SQL-01' 
      WITH (  ENDPOINT_URL = 'TCP://172.40.0.10:5022', 
              AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
              FAILOVER_MODE = AUTOMATIC,
              SEEDING_MODE = AUTOMATIC  ),
  'GB-SQL-02' 
      WITH (  ENDPOINT_URL = 'TCP://172.40.0.11:5022', 
              AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
              FAILOVER_MODE = AUTOMATIC,
              SEEDING_MODE = AUTOMATIC )
  "
  Write-Host $tSQL 
  Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-01" 

  # grant the AG to create a database
  $tSQL = "ALTER AVAILABILITY GROUP [$AGName] GRANT CREATE ANY DATABASE"
  Write-Host $tSQL 
  Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-01" 


  # join the secondary node and also grant create database
  $tSQL = "
  ALTER AVAILABILITY GROUP [$AGName] JOIN
  ALTER AVAILABILITY GROUP [$AGName] GRANT CREATE ANY DATABASE
  "
  Write-Host $tSQL 
  Invoke-SqlCmd -Query $tSQL -Serverinstance "GB-SQL-02" 

