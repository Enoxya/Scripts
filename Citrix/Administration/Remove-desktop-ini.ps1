$arrUsers = Get-ChildItem ("\\srv-ctx-file\Users$\Documents") | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.FullName}
Foreach ($strUser in $arrUsers) {
	$ErrorActionPreference = "SilentlyContinue"
	$strFile = $strUser + "\desktop.ini"
	Remove-Item -Path $strFile -Force
}