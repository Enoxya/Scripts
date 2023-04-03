
# ACTIVER ou DESACTIVER toutes les étendues
<#
param
(
  [Parameter(Mandatory=$false,ParameterSetName="Server",ValueFromPipelineByPropertyName=$true,Position=0,Helpmessage="DNS name or IP of server to work with")]$Server = "localhost"
)

$Server = "\\$Server"

$scopes = netsh dhcp server $server show scope

foreach($scope in $scopes){

$regex = [regex]"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"

$ip = $scope | foreach {$regex.Matches($_) | foreach {$_.Captures[0].Value}}
if($ip -ne $null){
#mettre set state 1 pour activer les etendues
& netsh dhcp server $server scope $ip[0] set state 0
}

} #>


# Paramétrer des options sur toutes les étendues

$TW_DHCPServer = "172.16.0.1"
$TW_DHCPScopes = Get-DhcpServerv4ScopeStatistics -ComputerName $TW_DHCPServer|Get-DhcpServerv4Scope -ComputerName $TW_DHCPServer

	Foreach ($TW_Scope in $TW_DHCPScopes)
{ 
# LES DNS
#Set-DhcpServerv4OptionValue -ComputerName SRV-NOR-DC1.groupe-bernard.lan -ScopeId $TW_Scope.ScopeId -DnsServer 172.16.0.1, 172.16.0.2 -Force
# Les serveurs FTP pour la platine WYSE
Set-DhcpServerv4OptionValue -ComputerName SRV-NOR-DC1.groupe-bernard.lan -scopeId $TW_Scope.ScopeId -OptionId 161 -Value 172.16.0.150
} 


