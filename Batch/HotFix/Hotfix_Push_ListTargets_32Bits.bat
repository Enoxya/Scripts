@ECHO OFF

SET listeOrdinateursCibles=ListeOrdinateursCibles_32Bits.txt
SET repertoireSource=\\obelix\services\G_DSIO\01.Documentations\01.Applications\Viewpoint - GE Healthcare\Documentation Technique\3-Installation client\
SET repertoireDestination=c$\temp\
SET repertoireCible=c:\temp\
SET KB=Windows6.1-KB2999226-x86.msu


REM for /f %%a in (%ListeOrdinateursCibles%) do mkdir c:\hotfix
for /f %%a in (%ListeOrdinateursCibles%) do xcopy /d/y "%repertoireSource%%KB%" /i \\%%a\%repertoireDestination%
psexec -s @%ListeOrdinateursCibles% wusa %repertoireCible%%KB% /passive /quiet /norestart
for /f %%a in (%ListeOrdinateursCibles%) do del \\%%a\%repertoireDestination%%KB%
pause

REM Error codes :
REM	-2145124329 	SUS_E_NOT_APPLICABLE	install is not needed because no updates are applicable
REM	-2359302				code that signifies the patch has already been installed
