Enable-PSRemoting

winrm set winrm/config/client '@{TrustedHosts="PCX-SECO-CM2"}'

.\PsExec.exe \\PCX-SECO-CM2 -s winrm.cmd quickconfig -q

Enter-PSSession -ComputerName PCX-SECO-CM2.chb.ts1.local
