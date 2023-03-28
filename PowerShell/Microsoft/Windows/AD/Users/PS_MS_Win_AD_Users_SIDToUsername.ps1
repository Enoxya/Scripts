
$objSID = New-Object System.Security.Principal.SecurityIdentifier `
    ("S-1-5-18")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value