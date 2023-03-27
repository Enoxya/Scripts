Asnp VeeamPssnapin
Foreach ($Job in Get-VBRJob)
{
$job | select name >> c:\users\exploit-bkp2\desktop\aaa.txt
"-------------------" >> c:\users\exploit-bkp2\desktop\aaa.txt
$Job |select @{Name="Objectsinjob";Expression={$_.GetObjectsInJob().name}} | select -expandproperty Objectsinjob >> c:\users\exploit-bkp2\desktop\aaa.txt
" "
}