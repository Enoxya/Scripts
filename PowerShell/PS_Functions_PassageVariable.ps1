
function foo($a, $b, $c) {
    "a: $a; b: $b; c: $c"
 }

 foo 1 2 3


#------------------------ PAR VALEUR
Function Test($data)
{
    $data = 3
    write-host "valeur dans la fonction :"$data
}

$var = 10
Write-Host "Valeur avant la fonction" :$var
Test -data $var
write-host "Valeur en dehors de la fonction :"$var


#------------------------ PAR REFERENCE
Function Test([ref]$data)
{
    $data.Value = 3
    write-host "valeur dans la fonction Test :"$data.Value
}

Function Test2([ref]$data2)
{
    $data2.Value = 5
    write-host "valeur dans la fonction Test2 :"$data2.Value
}

$var = 10
Write-Host "Valeur avant la fonction Test" :$var
Test -data ([ref]$var)
write-host "Valeur en dehors de la fonction Test et avant la fonction Test2 :"$var
Test2 -data2 ([ref]$var)
write-host "Valeur en dehors de la fonction Test2 :"$var