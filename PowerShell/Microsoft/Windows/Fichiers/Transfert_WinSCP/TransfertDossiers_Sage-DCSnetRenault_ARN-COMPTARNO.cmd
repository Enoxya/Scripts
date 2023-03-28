set dateDuJour=%DATE:~-2,4%%DATE:~-7,2%%DATE:~-10,2%
set fichierSource="\\SRV-NOR-FRP\Sage\ARN\ENCOURS\SOLDE_CLIENTS_%DateDujour%.csv"
"C:\Program Files (x86)\WinSCP\WinSCP.com" /ini=nul /script=TransfertDossiers_Sage-DCSnetRenault_ARN-COMPTARNO.txt /parameter %fichierSource%

