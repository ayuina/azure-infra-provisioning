<# 
.SYNOPSIS 
    Setup azure demo environment - paas
.NOTES 
    Created:  2019/08/02
#>

[CmdletBinding()]
Param (
    $name = "ayuina",
    $region = "southeastasia",
    $credential
)

### define variables 

$prefix = "$name-{0:MMdd}" -f [DateTime]::Now
$RESOURCE_GROUP = "$prefix-paas-rg"
$WEBAPP = "$prefix-web"
$APP_SERVICE_PLAN = "$webapp-asp"
$SQL_SERVER = "$prefix-sqlsvr"
$SQL_DATABASE = "$prefix-sqldb"
if($null -eq $credential)
{
    $credential = Get-Credential -Message "input SQL Database administoration credential"
}

####
Write-Verbose "Creating Resource Group"
New-AzResourceGroup -Name $RESOURCE_GROUP -Location $region `
    | Set-Variable rg

####
Write-Verbose "Creating App Service Plan"
New-AzAppServicePlan -Name $APP_SERVICE_PLAN -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -Tier Standard -WorkerSize Small -NumberofWorkers 2 `
    | Set-Variable asp

####
Write-Verbose "Creating Web app"
New-AzWebApp -Name $WEBAPP -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -AppServicePlan $APP_SERVICE_PLAN `
    | Set-Variable web

Write-Host ("Web site {0} created. " -f $web.HostNames[0])

####
Write-Verbose "Creating SQL Server"
New-AzSqlServer -ServerName $SQL_SERVER -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -SqlAdministratorCredentials $credential `
    | Set-Variable sqlsvr

####
Write-Verbose "Creating SQL Database"
New-AzSqlDatabase -DatabaseName $SQL_DATABASE -ResourceGroupName $RESOURCE_GROUP -ServerName $SQL_SERVER  `
    | Set-Variable sqldb

$fmt = "Server=tcp:{0},1433;Initial Catalog={1};User ID={2};Password={{your_password}};" 
$constr = $fmt -f $sqlsvr.FullyQualifiedDomainName, $sqldb.DatabaseName, $credential.UserName
Write-Host ("sql database created : ""{0}"" " -f $constr)


