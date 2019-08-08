<# 
.SYNOPSIS 
    Setup azure demo environment - iaas
.NOTES 
    Created:  2019/08/01
#>

[CmdletBinding()]
Param (
    [string]$name = "ayuina",
    [string]$region = "southeastasia",
    $credential
)

### define variables 

$prefix = "$name-{0:MMdd}" -f [DateTime]::Now
$RESOURCE_GROUP = "$prefix-iaas-rg"
$VNET_NAME = "$prefix-vnet"

$ADDRESS_FORMAT = "10.$([DateTime]::Now.Month).$([DateTime]::Now.Day).{0}/{1}"
$VNET_ADDRESS_PREFIX = $ADDRESS_FORMAT -f 0, 24
$WEB_SUBNET_ADDRESS_PREFIX = $ADDRESS_FORMAT -f 0, 27
$DB_SUBNET_ADDRESS_PREFIX = $ADDRESS_FORMAT -f 32, 27
$JB_SUBNET_ADDRESS_PREFIX = $ADDRESS_FORMAT -f 192, 27

if($null -eq $credential)
{
    $credential = Get-Credential -Message "input Virtual Machine administoration credential"
}

$JB_VM01 = "$name-jb01"
$JB_VM01_NIC = "$JB_VM01-nic"
$JB_VM01_PIP = "$JB_VM01-pip"

$JB_VM02 = "$name-jb02"
$JB_VM02_NIC = "$JB_VM02-nic"
$JB_VM02_PIP = "$JB_VM02-pip"

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

####
Write-Verbose "Creating Resource Group : $RESOURCE_GROUP"
New-AzResourceGroup -Name $RESOURCE_GROUP -Location $region

####
Write-Verbose "Creating Virtual Network : $VNET_NAME"
$websubnet = New-AzVirtualNetworkSubnetConfig -Name "web-subnet" -AddressPrefix $WEB_SUBNET_ADDRESS_PREFIX
$dbsubnet = New-AzVirtualNetworkSubnetConfig -Name "db-subnet" -AddressPrefix $DB_SUBNET_ADDRESS_PREFIX
$jbsubnet = New-AzVirtualNetworkSubnetConfig -Name "jb-subnet" -AddressPrefix $JB_SUBNET_ADDRESS_PREFIX
$vnet = New-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP -Name $VNET_NAME -Location $region `
    -AddressPrefix $VNET_ADDRESS_PREFIX -Subnet $websubnet, $dbsubnet, $jbsubnet

####
Write-Verbose "Creating Virtual Network Configuration : $JB_VM01 "
$jbpip = New-AzPublicIpAddress -Name $JB_VM01_PIP -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -Sku Basic -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel $JB_VM01
$subnet = $vnet.Subnets | Where-Object {$_.Name -eq $jbsubnet.Name}
$jbnic = New-AzNetworkInterface -Name $JB_VM01_NIC -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -SubnetId $subnet.Id -PublicIpAddressId $jbpip.Id

####
Write-Verbose "Creating Windows Jumppox : $JB_VM01 "
$vmconfig = New-AzVmConfig -VMName $JB_VM01 -VMSize "Standard_B2s" `
    | Add-AzVMNetworkInterface -Id $jbnic.Id `
    | Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "2019.0.20190603" `
    | Set-AzVMOperatingSystem -Windows -ComputerName $JB_VM01 -Credential $credential -ProvisionVMAgent -EnableAutoUpdate 
New-AzVm -ResourceGroupName $RESOURCE_GROUP -Location $region -VM $vmconfig `
    | Set-Variable jb01

####
$jbpip = Get-AzPublicIpAddress -Name $JB_VM01_PIP -ResourceGroupName $RESOURCE_GROUP
Write-Host ("Windows Jumpbos is created : mstsc /v:{0}" -f $jbpip.IpAddress )

####
Write-Verbose "Creating Virtual Network Configuration : $JB_VM02 "
$jbpip2 = New-AzPublicIpAddress -Name $JB_VM02_PIP -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -Sku Basic -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel $JB_VM02
$subnet2 = $vnet.Subnets | Where-Object {$_.Name -eq $jbsubnet.Name}
$jbnic2 = New-AzNetworkInterface -Name $JB_VM02_NIC -ResourceGroupName $RESOURCE_GROUP -Location $region `
    -SubnetId $subnet2.Id -PublicIpAddressId $jbpip2.Id

####
Write-Verbose "Creating Linux Jumppox  : $JB_VM02"
$vmconfig2 = New-AzVmConfig -VMName $JB_VM02 -VMSize "Standard_B2s" `
    | Add-AzVMNetworkInterface -Id $jbnic2.Id `
    | Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "19.04" -Version "19.04.201908010" `
    | Set-AzVMOperatingSystem -Linux -ComputerName $JB_VM02 -Credential $credential    
New-AzVm -ResourceGroupName $RESOURCE_GROUP -Location $region -VM $vmconfig2 `
    | Set-Variable jb02

####
$jbpip2 = Get-AzPublicIpAddress -Name $JB_VM02_PIP -ResourceGroupName $RESOURCE_GROUP
Write-Host ("Linux Jumpbos is created : ssh {0}@{1}" -f $credential.UserName, $jbpip2.IpAddress )
    


