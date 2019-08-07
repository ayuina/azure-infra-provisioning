<# 
.SYNOPSIS 
    Setup azure demo environment
.NOTES 
    Created:  2019/08/02
#>

[CmdletBinding()]
Param (
    $name = "ayuina",
    $region = "southeastasia"
)

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$cred = Get-Credential -Message "Input administration credential"

Write-Verbose "##### Start Deploy PaaS environment ####"
.\demo-paas.ps1 -name $name -region $region -credential $cred -Verbose

Write-Verbose "##### Start Deploy IaaS environment ####"
.\demo-Iaas.ps1 -name $name -region $region  -credential $cred -Verbose
