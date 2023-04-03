Search-ADAccount -lockedout | where-object {$_.enabled -eq 'True'} | Select Name
