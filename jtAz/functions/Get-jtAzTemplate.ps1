function Get-jtAzTemplate {
<#
.SYNOPSIS
    Returns a template that you can use for reference when deploying resources to Azure.

.DESCRIPTION
    Get-jtAzTemplate is a function that returns the template for the given resource found at https://docs.microsoft.com/en-us/azure/templates/.
    You can return the json-, the bicep template or both.

.PARAMETER providerNamespace
    The provider namespace

.PARAMETER resourceType
    The resource type. If no resource type is given this function will return all available resource types and api versions for the given provider namespace.

.PARAMETER apiVersion
    The API version. Default is 'Latest'. Multiple versions are allowed.
    For a list of all api versions for a given provider namespace run Get-jtAzTemplate -providerNamespace <providerNamespace>

.EXAMPLE
     Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases'

.EXAMPLE
     Get-jtAzTemplate -providerNamespace 'microsoft.sql' -resourceType 'servers/databases' -templateStructure Bicep

.EXAMPLE
     Get-jtAzTemplate -providerNamespace microsoft.sql -resourceType servers/databases -apiVersion '2020-08-01-preview'

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
        if (!$PSBoundParameters.ContainsKey('resourceType')) {
            Write-Verbose 'resourceType not given. Calling function Get-jtAzResourceTypes.'
            Get-jtAzResourceTypes -providerNamespace $providerNamespace
        } else {
            $baseUrl = 'https://docs.microsoft.com/azure/templates/'
            foreach ($version in $apiVersion) {
                try {
                    if ($apiVersion -eq 'Latest') {
                        $Uri = $baseUrl + $providerNamespace + '/' + $resourceType
                        Write-Verbose "apiVersion: $version. Resource URL: $Uri"
                    } else {
                        $Uri = $baseUrl + $providerNamespace + '/' + $version + '/' + $resourceType
                        Write-Verbose "apiVersion: $version. Resource URL: $Uri"
                    }

                    $response = Invoke-RestMethod -Uri $Uri

                    Write-Verbose "Part where we look for $templateStructure"
                    switch ($templateStructure) {
                        "ARM"   {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"')      }
                        "Bicep" {   $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                        "Both"  {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                                    $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                        Default {   $ARM    = ([regex]'(?<=lang-json">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value.Replace('&quot;','"'); `
                                    $Bicep  = ([regex]'(?<=lang-bicep">)[\S\s]*?(?=<\/code><\/pre>)').Matches($response)[0].Value                           }
                    }

                    Write-Verbose "Part where we create the output object"
                    $props = [ordered]@{'providerNamespace'  = $providerNamespace
                                        'resourceType'       = $resourceType
                                        'apiVersion'         = $apiVersion
                            
                                        'Template Reference' = $Uri

                                        'ARM'                = $ARM
                                        'Bicep'              = $Bicep}
                    $obj = New-Object -TypeName psobject -Property $props
                    Write-Output $obj
                } catch {
                    Write-Warning "FAILED to retrieve from URL: $Uri"
                    if ($check = Get-jtAzProviderNamespace -Name $providerNamespace) {
                        Write-Verbose "$providerNamespace is a valid provider namespace. Possible resource types are:"
                        $check | Get-jtAzResourceTypes
                    } else {
                        Write-Warning "The provider namespace '$providerNamespace' does not exist. Please run 'Get-jtAzProviderNamespace'."
                    }
                } #catch
            } #foreach
        } #else
    } #process
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    } #end
} # function