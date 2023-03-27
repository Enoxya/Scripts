netstat -na | find "3389" | find "ESTABLISHED" >> C:\path_to_rdplog.txt
date /T >> C:\path_to_rdplog.txt
time /T >> C:\path_to_rdplog.txt
echo. >> C:\path_to_rdplog.txt
echo ----------- >> C:\path_to_rdplog.txt
echo. >> C:\path_to_rdplog.txt