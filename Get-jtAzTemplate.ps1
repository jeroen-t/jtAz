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
    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand)"
    } #begin
    PROCESS {
        $baseUrl = 'https://docs.microsoft.com/azure/templates/'
        foreach ($version in $apiVersion) {
            if ($apiVersion -eq 'Latest') {
                $Uri = $baseUrl + $providerNamespace + '/' + $resourceType
                Write-Verbose "apiVersion: $version. Resource URL: $Uri"
            } else {
                $Uri = $baseUrl + $providerNamespace + '/' + $version + '/' + $resourceType
                Write-Verbose "apiVersion: $version. Resource URL: $Uri"
            } #todo: child resource?

            try {
                $response = Invoke-RestMethod -Uri $Uri -erroraction Stop
            }
            catch {
                catch [System.NullReferenceException]{
                Write-Host "There is no data" 
            }

            #todo: error handling ^

            Write-Verbose "Part where we look for $templateStructure"
            switch ($templateStructure) {
                "ARM"   {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"')      }
                "Bicep" {   $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                "Both"  {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                            $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                Default {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                            $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
            }
            # Write-Host "$ARM"

            Write-Verbose "Part where we create the output object"
            $props = [ordered]@{'providerNamespace'  = $providerNamespace
                                'resourceType'       = $resourceType
                                'apiVersion'         = $apiVersion
                       
                                'Template Reference' = $Uri

                                'ARM'                = $ARM
                                'Bicep'              = $Bicep}
            $obj = New-Object -TypeName psobject -Property $props
            Write-Output $obj
        } # foreach
    } #process
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    } #end
} # function


 Get-jtAzTemplate -providerNamespace microsoft.sql -resourceType servers/databases -templateStructure Bicep -apiVersion '2020-08-01-preview' -Verbose
#Get-jtAzTemplate microsoft.resources allversions Bicep

# Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases'

<#
https://docs.microsoft.com/azure/templates/{provider-namespace}/{resource-type}
$providerNamespace = 'microsoft.sql'
$resourceType = 'servers/databases'

https://docs.microsoft.com/en-us/azure/templates/toc.json
#>
