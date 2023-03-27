forfiles /S /P "c:\temp\photos" /D -0  /c "cmd /c IF @EXT == txt dir c:\temp\photos"
pause
dir c:\temp\photos
pause