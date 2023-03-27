

#get max password age policy
$maxPwdAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days

#expiring in 7 days
$7days=(get-date).AddDays(7-$maxPwdAge).ToShortDateString()

$EmailList = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} –Properties * |
             where {($_.PasswordLastSet).ToShortDateString() -le $7days} |
             Select-Object EmailAddress

$EmailFrom = "code.example@email.com"
$EmailCc = "code.example2@email.com"

$EmailSubject = "Example subject"

$emailbody = "example body"
$SMTPServer = "192.168.8.130"

foreach ($element in $EmailList) {
  $output = Out-String -InputObject $element ;
  if ($finaloutput=$output.Contains(".")) {
    Send-MailMessage -SmtpServer $SMTPServer -From $EmailFrom -To $output -Cc $EmailCc -Subject $EmailSubject -Body $emailbody -Bodyashtml;
  }
}