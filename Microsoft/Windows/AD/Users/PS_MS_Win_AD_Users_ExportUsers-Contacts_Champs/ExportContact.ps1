﻿Get-ADObject -LDAPFilter "objectClass=Contact" -Properties "mail" | Export-Csv "Blabla.csv" -NoType