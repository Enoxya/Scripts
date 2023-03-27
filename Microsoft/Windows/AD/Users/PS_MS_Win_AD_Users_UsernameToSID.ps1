#This will give you a Domain User's SID

$objUser = New-Object System.Security.Principal.NTAccount("DOMAIN_NAME", "USER_NAME") 
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
$strSID.Value