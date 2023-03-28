
$file = Get-Item D:\CENG\Fichiers\PRODUCTION\Import\Medical\PN13\Prescriptions\HM\SVG2\aa
$file2 = Get-Item D:\CENG\Fichiers\PRODUCTION\Import\Medical\PN13\Prescriptions\HM\SVG2\aa\aa.txt
$file.LastWriteTime = (Get-Date).AddDays(-240)
$file2.LastWriteTime = (Get-Date).AddDays(-240)
