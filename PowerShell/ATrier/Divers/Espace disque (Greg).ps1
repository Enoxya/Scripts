#########################################################
#                                                       #
# Monitoring Disk Space									#
#                                                       #
#########################################################
param (
      $serverList =  "c:\list.txt" # Local drive where is server list 
)

$users = "g.buenadicha@autobernard.com" #List of user will receive report.
$fromemail = "Espace_Disque_Faible@autobernard.com" # From email
$server = "exch-relais.groupe-bernard.lan" #SMTP Server.
$computers = Get-Content $serverList


[decimal]$thresholdspace = 15 # % of disk space
$critical=8 # critical value. Show red
[System.Array]$results = foreach ($cmp in $computers) { 
 Get-WMIObject  -ComputerName $cmp Win32_LogicalDisk |
where{($_.DriveType -eq 3) -and (($_.freespace/$_.size*100) -lt $thresholdspace) }|
select @{n='Nom du serveur' ;e={"{0:n0}" -f ($cmp)}},
@{n='Nom du volume' ;e={"{0:n0}" -f ($_.volumename)}},
@{n='Lettre du lecteur' ;e={"{0:n0}" -f ($_.name)}},
@{n='Taille totale (Gb)' ;e={"{0:n2}" -f ($_.size/1gb)}},
@{n='Espace libre (Gb)';e={"{0:n2}" -f ($_.freespace/1gb)}},
@{n='Pourcentage libre';e={"{0:n2}%" -f ($_.freespace/$_.size*100)}}
}


$tableStart="<table style='boder:0px 0px 0px 0px;'><tr><th>Nom du serveur</th><th>Nom du volume</th><th>Lettre du lecteur</th>
<th>Taille totale (Gb)</th><th>Espace libre (Gb)</th><th>Pourcentage libre</th></tr>"

$allLines=""
for($i=0;$i -lt $results.Length;$i++){
     #get variables
     $servers=($results[$i] | select -ExpandProperty "Nom du serveur"  )
     $volumes=($results[$i] | select -ExpandProperty "Nom du volume" )
     $drives=($results[$i] | select -ExpandProperty "Lettre du lecteur" )
     $capac=($results[$i] | select -ExpandProperty "Taille totale (Gb)" )
     $freeSpace=($results[$i] | select -ExpandProperty "Espace libre (Gb)" )
     $percentage=($results[$i] | select -ExpandProperty "Pourcentage libre" )
     
     #Change Color Lines
     if(($i % 2) -eq 0){
         $beginning="<tr style='background-color:white;'>"
     }else{
         $beginning="<tr style='background-color:rgb(245,245,245);'>"
     }
     #Build body
     $bodyEl ="<td> " + $servers+ " </td>" 
     $bodyEl+="<td> " + $volumes + " </td>"
     $bodyEl+="<td style='text-align:center;'> " + $drives + " </td>"
     $bodyEl+="<td style='text-align:center;'> " + $capac + " </td>"
     $bodyEl+="<td style='text-align:center;'> " + $freeSpace + " </td>"
     $fr=[System.Double]::Parse($freeSpace)
     $cap=[System.Double]::Parse($capac)
     if((($fr/$cap)*100) -lt [System.Int32]::Parse($critical)){
         $bodyEl+= "<td style='color:red;font-weight:bold;text-align:center;'>"+$percentage +"</td>"
     }
     else{
         $bodyEl+="<td style='color:green;font-weight;text-align:center;'>"+$percentage +"</td>"
     }    
     $end="</tr>"
     $allLines+=$beginning+$bodyEl+$end
}
$tableBody=$allLines
$tableEnd="</table>"
$tableHtml=$tableStart+$tableBody+$tableEnd

# HTML Output Format 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>Rapport d'espace disque libre</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>Vous recevez cet Email  car le(s) volume(s) ci-dessous ont moins de $thresholdspace % d'espace libre. Les volumes au dessus de cette limite n'ont pas été listés.</p>
<br><br>
<style type=""text/css"">body{font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;}
ol{margin:0;}
table{width:80%;}
thead{}
thead th{font-size:120%;text-align:left;}
th{border-bottom:2px solid rgb(79,129,189);border-top:2px solid rgb(79,129,189);padding-bottom:10px;padding-top:10px;}
tr{padding:10px 10px 10px 10px;border:none;}
#middle{background-color:#900;}
</style>
<body BGCOLOR=""white"">
$tableHtml
</body>
"@

# Regular Expression <td> <td>
$regexsubject = $HTMLmessage
$regex = [regex] '(?im)<td>'

$msg = New-Object Net.Mail.MailMessage

# if have data 	send email.
if ($regex.IsMatch($regexsubject)) {
     $smtpServer=$server
     $smtp = New-Object Net.Mail.SmtpClient -arg $smtpServer
     $msg.From = $fromemail
     $msg.To.Add($users)
     $msg.Subject = "Espace disque faible"
     $msg.IsBodyHTML = $true
     $msg.Body = $HTMLmessage 
      $smtp.Send($msg)   
}