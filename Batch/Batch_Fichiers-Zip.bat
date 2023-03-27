@ECHO ON

SET SourceDir=C:\folder\source
SET DestDir=C:\folder\destination

CD /D "C:\Program Files\7-Zip"
FOR /F "TOKENS=*" %%F IN ('DIR /B /A-D "%SourceDir%"') DO (
    7z.exe a "%DestDir%\%%~NF.zip" "%SourceDir%\%%~NXF"
)
EXIT


Or with a command line :

FOR /F "TOKENS=*" %F IN ('DIR /B /A-D "C:\Folder\Source"') DO 7z.exe a "C:\Folder\Dest\%~NF.zip" "C:\Folder\Source\%~NXF"