
set colsep '|'
set echo off
set feedback off
set linesize 1000
set sqlprompt ''
set trimspool on
set headsep on

SELECT UCD13 as ucd, PHARMACOPD as ucd, PHARMACOPD2 as ucd, LIBCALCPR AS nom_produit, STOCK AS stock, (SELECT SUM(MVTPDT.QUANTITE) / 6 FROM MVTPDT 
WHERE MVTPDT.PRCLEUNIK=PRODUIT.PRCLEUNIK AND MVTPDT.TYPEMVT = 7 AND MVTPDT.DATEMVT >= to_date( TO_CHAR ((SYSDATE - 6 ), 'YYYYMMDD'), 'YYYYMMDD') 
AND MVTPDT.DATEMVT < to_date( TO_CHAR (SYSDATE, 'YYYYMMDD'),'YYYYMMDD' ) ) as conso_jour FROM PRODUIT,grpdt,multigrp WHERE PRODUIT.PRCLEUNIK >0 
AND produit.prcleunik = multigrp.prcleunik AND multigrp.grcleunik = grpdt.grcleunik AND grpdt.codegr='REA_ARS' ORDER BY LIBCALCPR

spool ./resultat_e-dispostock.csv
/
spool off

exit
