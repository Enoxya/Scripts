rem echo off
forfiles /S /P "c:\temp\photos" /D -0  /c "cmd /c IF @isdir == TRUE rd /s /Q @path"
rem echo on 


forfiles /S  /P "c:\temp\photos" /D -0 /C "cmd /c DEL @path"