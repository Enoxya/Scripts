$objUser = New-Object System.Security.Principal.NTAccount("LOCAL_USER_NAME") 
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
$strSID.Value