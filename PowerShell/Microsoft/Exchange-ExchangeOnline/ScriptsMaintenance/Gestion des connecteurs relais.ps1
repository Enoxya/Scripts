# -----------------------------------------------
# ADMINISTRATION EXCHANGE
# -----------------------------------------------

# ---- CONNEXION AU POWERSHELL EXCHANGE
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session
#Remove-PSSession $Session


# ---- GESTION DES CONNECTEURS RELAIS ENVOI SMTP ----

  # Récupérer les IP de l'ancien connecteur
  $RConn= Get-receiveConnector "SRV-NOR-EXCH1\Relais SMTP"
  $RConn.RemoteIpRanges | ft LowerBound,CIDRLength -AutoSize 
  $RConn.RemoteIpRanges.count
  
  # Affecter les valeurs au nouveau serveur
  Set-ReceiveConnector "SRV-NOR-MBX1\Relais Externe" -RemoteIPRanges $RConn.RemoteIPRanges
  Set-ReceiveConnector "SRV-NOR-MBX2\Relais Externe" -RemoteIPRanges $RConn.RemoteIPRanges
  
    # Ajouter une adresse IP au connecteur externe
  $RConnExt = Get-ReceiveConnector "SRV-NOR-MBX1\Relais Externe"
  $RConnExt.RemoteIpRanges.count
  $RConnExt.RemoteIPRanges += "172.16.0.100"
  Set-ReceiveConnector "SRV-NOR-MBX1\Relais Externe" -RemoteIPRanges $RConnExt.RemoteIPRanges
  Set-ReceiveConnector "SRV-NOR-MBX2\Relais Externe" -RemoteIPRanges $RConnExt.RemoteIPRanges
 
  # Ajouter une adresse IP au connecteur interne
  $RConnInt = Get-ReceiveConnector "SRV-NOR-CAS1\Relais Interne"
  $RConnInt.RemoteIpRanges.count
  $RConnInt.RemoteIPRanges += "172.16.0.100"
  Set-ReceiveConnector "SRV-NOR-CAS1\Relais Interne" -RemoteIPRanges $RConnInt.RemoteIPRanges
  Set-ReceiveConnector "SRV-NOR-CAS2\Relais Interne" -RemoteIPRanges $RConnInt.RemoteIPRanges
 
  # ----------------------------- #
  
  # Comparaison des relais
  $RConn1= Get-receiveConnector "SRV-NOR-CAS1\Relais Interne"
  $RConn1.RemoteIpRanges.count
  $RConn2= Get-receiveConnector "SRV-NOR-CAS2\Relais Interne"
  $RConn2.RemoteIpRanges.count
  Compare-Object $RConn1.RemoteIpRanges $RConn2.RemoteIpRanges
 
  # Récupérer les IP sur le serveur CAS1
  $RConnC = Get-receiveConnector "SRV-NOR-CAS1\Relais Interne"
  $RConnC.RemoteIpRanges | ft LowerBound,CIDRLength -AutoSize 
  $RConnC.RemoteIpRanges.count
 
  # Appliquer au CAS2
  Set-ReceiveConnector "SRV-NOR-CAS2\Relais Interne" -RemoteIPRanges $RConnC.RemoteIPRanges
 
  # Vérification
  $RConnC = Get-receiveConnector "SRV-NOR-CAS2\Relais Interne"
  $RConnC.RemoteIpRanges | ft LowerBound,CIDRLength -AutoSize 
  $RConnC.RemoteIpRanges.count
 

 # Activation des logs

 
 # Exploitation des logs
C:
CD\
CD '.\Program Files (x86)\Log Parser 2.2'
.\logparser.exe "SELECT session-id, remote-endpoint, data from Z:\RECV20150407-1.log WHERE data LIKE '%EHLO%' OR DATA LIKE '%HELO%' OR data LIKE `
                '%RCPT TO%' GROUP BY session-id, remote-endpoint, data" -i:CSV -nSkipLines:4 -rtp:-1
 
 

 