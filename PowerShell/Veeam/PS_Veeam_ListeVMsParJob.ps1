Asnp VeeamPssnapin
Foreach ($Job in Get-VBRJob)
{
$job | Select-Object name >> c:\users\exploit-bkp2\desktop\aaa.txt
"-------------------" >> c:\users\exploit-bkp2\desktop\aaa.txt
$Job |Select-Object @{Name="Objectsinjob";Expression={$_.GetObjectsInJob().name}} | Select-Object -expandproperty Objectsinjob >> c:\users\exploit-bkp2\desktop\aaa.txt
" "
}