
ldappasswd -x -D 'uid=$user,ou=Users,dc=example,dc=com' -W -S

#Trouver les users
ldapsearch -x -b "dc=ch-valence,dc=lan" -S uid > /tmp/listeusersldap.txt