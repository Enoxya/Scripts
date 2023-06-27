:Start
cls
@echo off
Echo.
Echo Remote Windows Update Check (Multiple Targets)
Echo.

FOR /F %%C IN (aa.txt) DO (

sc \\%%C stop wuauserv
TIMEOUT /T 10
sc \\%%C start wuauserv
TIMEOUT /T 10

psexec \\%%C -s wuauclt /resetauthorization /detectnow
TIMEOUT /T 5
psexec \\%%C -s wuauclt /reportnow

)

Goto End

:End