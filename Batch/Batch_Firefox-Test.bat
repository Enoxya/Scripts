@echo off
if exist "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" (goto :x86) else (goto :x64)

:x64
start "" "C:\Program Files\Mozilla Firefox\firefox.exe"
goto END

:x86
start "" "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
goto END


:END
EXIT
