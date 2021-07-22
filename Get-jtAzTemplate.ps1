function Get-jtAzTemplate {

<#
.SYNOPSIS
    Returns a template that you can use for reference when deploying resources to Azure.

.DESCRIPTION
    Get-jtAzTemplate is a function that returns the template for the given resource found at https://docs.microsoft.com/en-us/azure/templates/.
    You can return the json-, the bicep template or both.

.PARAMETER ProviderNamespace
    The the provider namespace

.PARAMETER ResourceType
    The resource type

.EXAMPLE
     Get-jtAzTemplate -ProviderNamespace 'microsoft.sql' -ResourceType 'servers/databases'

.EXAMPLE
     Get-jtAzTemplate -ProviderNamespace 'microsoft.sql' -ResourceType 'servers/databases' -dsl Bicep

.INPUTS
    String

.OUTPUTS
    # todo: PSCustomObject

.NOTES
    Author:  Jeroen Trimbach
    Website: https://jeroentrimbach.com
#>

    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$ProviderNamespace,
        
        [Parameter(Position=1,Mandatory=$true)]
        [string]$ResourceType,

        [Parameter(Position=2,Mandatory=$false)]
        [ValidateSet("ARM","Bicep","Both")]
        [string]$dsl
    )
# https://docs.microsoft.com/azure/templates/{provider-namespace}/{resource-type}
# $ProviderNamespace = 'microsoft.sql'
# $ResourceType = 'servers/databases'
$response = Invoke-RestMethod -Uri "https://docs.microsoft.com/azure/templates/$ProviderNamespace/$ResourceType"
# $response = Invoke-RestMethod -Uri 'https://docs.microsoft.com/azure/templates/microsoft.sql/servers/databases'

# $dbs.Content | Select-String -Pattern '(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)' | Select-Object -ExpandProperty Matches


$match = ([regex]'(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)
switch ($dsl) {
    "ARM"   { $match[0].Value.Replace('&quot;','"');                 }
    "Bicep" { $match[1].Value;                                       }
    "Both"  { $match[0].Value.Replace('&quot;','"'); $match[1].Value }
    Default { $match[0].Value.Replace('&quot;','"'); $match[1].Value }
}

# https://docs.microsoft.com/en-us/azure/templates/toc.json

}

Get-jtAzTemplate -ProviderNamespace 'microsoft.sql' -ResourceType 'servers/databases'