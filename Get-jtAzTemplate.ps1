function Get-jtAzTemplate {

<#
.SYNOPSIS
    Returns a template that you can use for reference when deploying resources to Azure.

.DESCRIPTION
    Get-jtAzTemplate is a function that returns the template for the given resource found at https://docs.microsoft.com/en-us/azure/templates/.
    You can return the json-, the bicep template or both.

.PARAMETER providerNamespace
    The the provider namespace

.PARAMETER resourceType
    The resource type

.EXAMPLE
     Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases'

.EXAMPLE
     Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases' -templateStructure Bicep

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
        [Parameter(Position=0,Mandatory=$false)]
        [string]$providerNamespace, # = 'microsoft.resources'
        
        [Parameter(Position=1,Mandatory=$false)]
        [string]$resourceType, # = 'deployments'

        [Parameter(Position=1,Mandatory=$false)]
        [string[]]$apiVersion = 'Latest',

        [Parameter(Position=3,Mandatory=$false)]
        [ValidateSet("ARM","Bicep","Both")]
        [string]$templateStructure
    )
    BEGIN {}
    PROCESS {
        $baseUrl = 'https://docs.microsoft.com/azure/templates/'
        foreach ($version in $apiVersion) {
            if ($version -eq 'Latest') {
                $Uri = $baseUrl + $providerNamespace + '/' + $resourceType
            } else {
                $Uri = $baseUrl + $providerNamespace + '/' + $version + '/' + $resourceType
            }
            $response = Invoke-RestMethod -Uri $Uri
            
            # $match =  ([regex]'(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)
            # $amatch = ([regex]'(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)
            # $bmatch = ([regex]'(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)

            # $ARM = $match[0].Value.Replace('&quot;','"')
            # $Bicep = $match[1].Value

            switch ($templateStructure) {
                "ARM"   {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"')      }
                "Bicep" {   $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                "Both"  {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                            $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                Default {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                            $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
            }
            # Write-Host "$ARM"

            $props = [ordered]@{'providerNamespace'  = $providerNamespace
                                'resourceType'       = $resourceType
                                'apiVersion'         = $apiVersion
                       
                                'Template Reference' = $baseUrl

                                'ARM'                = $ARM
                                'Bicep'              = $Bicep}
            $obj = New-Object -TypeName psobject -Property $props
            Write-Output $obj
        } # foreach
    }
    END {}





    # https://docs.microsoft.com/azure/templates/{provider-namespace}/{resource-type}
    # $providerNamespace = 'microsoft.sql'
    # $resourceType = 'servers/databases'


# $baseUrl = 'https://docs.microsoft.com/azure/templates/'
# $Uri = $baseUrl + $providerNamespace + '/' + $resourceType
# $response = Invoke-RestMethod -Uri $Uri
# # $response = Invoke-RestMethod -Uri 'https://docs.microsoft.com/azure/templates/microsoft.sql/servers/databases'
# # $response
# # $dbs.Content | Select-String -Pattern '(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)' | Select-Object -ExpandProperty Matches


# $match = ([regex]'(?<=lang-bicep">|lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)
# switch ($templateStructure) {
#     "ARM"   { $match[0].Value.Replace('&quot;','"');                 }
#     "Bicep" { $match[1].Value;                                       }
#     "Both"  { $match[0].Value.Replace('&quot;','"'); $match[1].Value }
#     Default { $match[0].Value.Replace('&quot;','"'); $match[1].Value }
# }

# https://docs.microsoft.com/en-us/azure/templates/toc.json

}


 Get-jtAzTemplate -providerNamespace microsoft.sql -resourceType servers/databases -templateStructure Bicep
#Get-jtAzTemplate microsoft.resources allversions Bicep

# Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases'