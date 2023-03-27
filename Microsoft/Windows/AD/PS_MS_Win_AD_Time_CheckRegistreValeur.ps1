$servers=(Get-ADComputer -Filter 'operatingsystem -like "*server*"-and enabled -eq "true"').Name

$result=@()

foreach ($server in $serveurs) {
    $type=Invoke-Command -ComputerName $serveur {Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\' -Name Type} | select Type
    $result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
        'MACHINE'= $s
        'TYPE' = $type
    })
}


$result | Export-Csv "C:\users\ssaunier\Desktop\AD_ServiceTemps_Serveurs_20201023.csv" -NoTypeInformation -Encoding UTF8




#Invoke-Command -ComputerName RIS-XPlore {Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\' -Name Type | Select Type}