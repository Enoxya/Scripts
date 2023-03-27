set dateDuJour=%DATE:~-2,4%%DATE:~-7,2%%DATE:~-10,2%
set fichierSource="\\SRV-NOR-FRP\Sage\NIS\ENCOURS\SOLDE_CLIENTS_%dateDujour%.csv"
"C:\Program Files (x86)\WinSCP\WinSCP.com" /ini=nul /script=TransfertDossiers_Sage-DCSnetRenault_NIS-COMPTANIS.txt /parameter %fichierSource%

