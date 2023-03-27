Import-Module ActiveDirectory  

$users = $null

#OU=Sans accès direct à Internet
$users = Get-ADUser -SearchBase "OU=TestGPO,OU=FD-Utilisateurs,OU=VILLEO,DC=acgservices,DC=local" -Filter * | foreach {
    $user = [ADSI]"LDAP://$($_.DistinguishedName)"
	if ($user.TerminalServicesProfilePath -isnot [System.Management.Automation.PSMethod])
	{
        $user.psbase.invokeSet("TerminalServicesProfilePath","")
        $user.psbase.invokeSet("TerminalServicesHomeDirectory","")
 		#$user.psbase.invokeSet("TerminalServicesHomeDrive","D")
		$user.setinfo()
	}
}