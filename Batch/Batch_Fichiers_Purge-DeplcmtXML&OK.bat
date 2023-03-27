@echo off

REM Vidage du repertoire de backup (suppression des fichiers de plus de 45 jours)
set repertoireActes_backup=E:\Hemadialyse_Interfaces\Actes\sauve\exports

forfiles -p %repertoireActes_backup% -s -m *.xml -d -45 -c "cmd /c del @FILE"
forfiles -p %repertoireActes_backup% -s -m *.ok -d -45 -c "cmd /c del @FILE"


REM Copie des fichiers .xml vers les repertoires pour envoi à HM et Cora dans un premier temps
REM Et copie des fichiers .ok vers les repertoires pour envoi à HM et Cora dans un second temps

set repertoireActes_origine=E:\Hemadialyse_Interfaces\Actes\sauve

forfiles -p %repertoireActes_origine% -m *.xml -c ^"cmd /c ^
copy @FILE E:\Hemadialyse_Interfaces\Actes\HM ^&^
copy @FILE E:\Hemadialyse_Interfaces\Actes\Cora^"

forfiles -p %repertoireActes_origine% -m *.ok -c ^"cmd /c ^
copy @FILE E:\Hemadialyse_Interfaces\Actes\HM ^&^
copy @FILE E:\Hemadialyse_Interfaces\Actes\Cora^"


REM Deplacement des fichiers .xml vers le repertoire de backup et suppression des fichiers .ok
forfiles -p %repertoireActes_origine% -m *.xml -c "cmd /c move @FILE %repertoireActes_backup%"
forfiles -p %repertoireActes_origine% -m *.ok -c "cmd /c del @FILE"





