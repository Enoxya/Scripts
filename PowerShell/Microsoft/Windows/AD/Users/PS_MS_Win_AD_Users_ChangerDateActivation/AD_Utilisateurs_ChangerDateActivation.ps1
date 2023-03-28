$users = ForEach ($user in $(Get-Content C:\Users\saunies\Desktop\liste.txt)) {
	Set-ADAccountExpiration -Identity $user -DateTime "24/03/2018"   
}