$SID = Read-Host "ENTER SID VALUE" 
$objSID = New-Object System.Security.Principal.SecurityIdentifier("$SID") 
$objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
$objUser.Value