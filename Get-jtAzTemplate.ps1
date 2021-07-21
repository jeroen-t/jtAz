function Get-jtAzTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$providernamespace,
        
        [Parameter(Position=1,Mandatory=$true)]
        [string]$resourcetype,

        [Parameter(Position=2,Mandatory=$false)]
        [ValidateSet("ARM","Bicep","Both")]
        [string]$dsl
    )
# https://docs.microsoft.com/azure/templates/{provider-namespace}/{resource-type}
# $providernamespace = 'microsoft.sql'
# $resourcetype = 'servers/databases'
$response = Invoke-RestMethod -Uri "https://docs.microsoft.com/azure/templates/$providernamespace/$resourcetype"
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

Get-jtAzTemplate -providernamespace 'microsoft.sql' -resourcetype 'servers/databases'