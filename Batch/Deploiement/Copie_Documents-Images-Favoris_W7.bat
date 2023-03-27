
SET Marque=Citroen
SET Concession=Macon
SET NomUtilisateur=%username%
SET Destination="\\srv-xen-prf01\Citroen-Utilisateurs$"

MKDIR \\srv-xen-prf01\Logs\Copie\%Marque%
MKDIR \\srv-xen-prf01\Logs\Copie\%Marque%\%Concession%
MKDIR \\srv-xen-prf01\Logs\Copie\%Marque%\%Concession%\%NomUtilisateur%


REM Documents
Robocopy "%userprofile%\Documents" %Destination%\%NomUtilisateur%\Documents /E /XJF /XJD /XA:SH /XF desktop.ini /XD "%userprofile%\Documents\Mes images" "%userprofile%\Documents\Ma Musique" "%userprofile%\Documents\Mes vidéos" /R:1 /W:1 /SEC /log:\\srv-xen-prf01\Logs\Copie\%Marque%\%Concession%\%NomUtilisateur%\Documents.log

REM Mes Images
Robocopy "%userprofile%\Pictures" "%Destination%\%NomUtilisateur%\Documents\Mes Images" /E /XJF /XJD /XA:SH /XF desktop.ini /R:1 /W:1 /SEC /log:"\\srv-xen-prf01\Logs\Copie\%Marque%\%Concession%\%NomUtilisateur%\Images.log"

REM Favoris
Robocopy "%userprofile%\Favorites" "%Destination%\%NomUtilisateur%\Favorites" /E /XJF /XJD /XA:SH /XF desktop.ini /R:1 /W:1 /SEC /log:"\\srv-xen-prf01\Logs\Copie\%Marque%\%Concession%\%NomUtilisateur%\Favoris.log"


pause