$computername = "SRV-NOR-DC1.groupe-bernard.lan"

$scopes = Get-DHCPServerv4Scope -ComputerName $computername |
Select-Object "Name","SubnetMask","StartRange","EndRange","ScopeID"

$lines = @()

$serveroptions = Get-DHCPServerv4OptionValue -ComputerName $computername -All | 
Select-Object Name,Value,VendorClass,UserClass

ForEach ($scope in $scopes) {

    ForEach ($option in $serveroptions) {

        $lines += $scope | Select-Object *,@{
            "Name"="OptionScope"
            "Expression"={ "Server" }},@{
            "Name"="OptionName"
            "Expression"={ $option.name }},@{
            "Name"="OptionValue"
            "Expression"={ $option.Value }},@{
            "Name"="OptionVendorClass"
            "Expression"={ $option.VendorClass }},@{
            "Name"="OptionUserClass"
            "Expression"={ $option.UserClass }}

    }

    $scopeoptions = Get-DhcpServerv4OptionValue -ComputerName $computername -ScopeId "$($scope.ScopeId)" -All | 
    Select-Object Name,Value,VendorClass,UserClass

    ForEach ($option in $scopeoptions) {

        $lines += $scope | Select-Object *,@{
            "Name"="OptionScope"
            "Expression"={ "Scope" }},@{
            "Name"="OptionName"
            "Expression"={ $option.name }},@{
            "Name"="OptionValue"
            "Expression"={ $option.Value }},@{
            "Name"="OptionVendorClass"
            "Expression"={ $option.VendorClass }},@{
            "Name"="OptionUserClass"
            "Expression"={ $option.UserClass }}

    }

}

$lines | Export-Csv -Path C:\Users\mayn\Desktop\dhcp.csv -NoTypeInformation