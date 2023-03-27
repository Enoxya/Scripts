$path = "\\obelix\services"
dir $path -Recurse | where { $_.PsIsContainer } | 
% { $path = $_.fullname; Get-Acl $_.Fullname | 
% { $_.access | where { $_.IdentityReference -like "Tout le monde" }}} | 
export-csv "export.csv"