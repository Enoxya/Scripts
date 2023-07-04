function Get-DFSNamespacePath
{
  param(
    [Parameter(Mandatory=$False, ValueFromPipeline=$true)]
    [ValidatePattern('[\w\{\}\.\-\*]+$')]
    [string[]]$Namespace,

    [Parameter(Mandatory=$False)]
    [string]$Domain
  )

  # Check if Domain name was supplied
  $DomainSplat = @{}
  if($PSBoundParameters.ContainsKey('Domain'))
  {
    $DomainSplat['Identity'] = $Domain
  }
  
  # Grab user domain and System container DN
  $DomainInfo = Get-ADDomain @DomainSplat
  $SystemDN   = $DomainInfo.SystemsContainer

  # Create namespace clause to search LDAP by name, multiple names and wildcard filter allowed
  if($PSBoundParameters.ContainsKey('Namespace'))
  {
    $NamespaceClauses = ($Namespace |ForEach-Object { "(name=$_)" }) -join ''
    $NamespaceClause  = '(|{0})' -f $NamespaceClauses
  }

  # Define final LDAP query filter and search base
  $NamespaceSplat = @{
    LDAPFilter = '(&(objectClass=msDFS-Namespacev2){0})' -f $NamespaceClause
    SearchBase = 'CN=Dfs-Configuration,{0}' -f $SystemDN
    Server = $DomainInfo.DNSRoot
  }

  # Query directory for namespace objects, output UNC paths
  Get-ADObject @NamespaceSplat |ForEach-Object {
    '\\{0}\{1}' -f $DomainInfo.DNSRoot,$_.Name
  }
}