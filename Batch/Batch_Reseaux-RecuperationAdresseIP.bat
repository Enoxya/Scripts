@echo off
for /F "delims=," %%i in ('ipconfig /all^|find "Adresse IP"') do set ADRIP=%%i
set ADRIP=%ADRIP:~44,15%
echo %ADRIP% >ip.txt
start notepad.exe /ip.txt
exit