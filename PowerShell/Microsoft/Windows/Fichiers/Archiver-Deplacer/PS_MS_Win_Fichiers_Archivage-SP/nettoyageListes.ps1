[void][System.reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

cls
echo "------ demarrage du script ------"  >> c:\scripts\nettoyage.log 
#préciser ici le site et la liste concernée
 
$site = new-object Microsoft.SharePoint.SPSite("http://sharepoint.autobernard.com/sites/intranet/VO")

$web = $site.openweb() 
$list = $web.Lists["Photos VO"]

if (!$list) {
write-host "La liste est introuvable. Ci-dessous les listes présentes :"
echo "La liste est introuvable."  >> c:\scripts\nettoyage.log 
$libraries = $web.lists | Where-Object { $_.BaseType -Eq "DocumentLibrary" } 
$libraries | Format-Table title,id -AutoSize
exit
} else {write-host "liste OK"} 

#requete CAML d'extraction des dates de création des fichiers
$caml="<Query>
    <And>
         <IsNotNull>
            <FieldRef Name='Created' />
         </IsNotNull>
         <Eq>
            <FieldRef Name='FSObjType' />
        <Value Type='Integer'>0</Value>
         </Eq>
      </And>
   <OrderBy>
      <FieldRef Name='Filename' Ascending='False' />
   </OrderBy>
 </Query>"

$query=new-object Microsoft.SharePoint.SPQuery 
$query.Query=$caml | Write-Output
$query.ViewAttributes = "Scope='Recursive'";
#echo $caml
$items=$list.GetItems($query)  
$listItemsTotal = $items.Count;

#parcours et selection des dates anterieures Ã  X jours
#mettre le nb de jours ici :
$age=30;

write-host "Liste des fichiers datant de plus de " $age "jours"
echo "liste des fichiers à nettoyer :" >> c:\scripts\nettoyage.log 
for($x=$listItemsTotal-1;$x -ge 0; $x--)
{
if ($items[$x]["Created"] -Lt (get-date).adddays($age * -1)) {
$o=$items[$x].name + "`t" + $items[$x]["Created"] + "`n"
Add-Content c:\scripts\nettoyage.log $o
#mettre en rem la ligne ci-dessous pour les tests 
$items[$x].delete()
 }
}



$web.Dispose() 
$site.Dispose() 


