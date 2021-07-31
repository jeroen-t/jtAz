function Get-jtAzResourceTypes {
<#
.SYNOPSIS
    Returns all the resource types and api versions for a given provider namespace.

.DESCRIPTION
    Get-jtAzResourceTypes is a function that returns the all the resource types and api versions for the given provider namespace found at https://docs.microsoft.com/en-us/azure/templates/.

.PARAMETER providerNamespace
    The provider namespace

.EXAMPLE
     Get-jtAzResourceTypes -providerNamespace 'microsoft.sql'

.EXAMPLE
     Get-jtAzResourceProvider -Name sql | Get-jtAzResourceTypes -Verbose

.INPUTS
    String

.OUTPUTS
    object[]

.NOTES
    Author:  Jeroen Trimbach
    Website: https://jeroentrimbach.com
#>
    param (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [string[]]$providerNamespace
    )
    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand)"
    }
    PROCESS {
        foreach ($provider in $providerNamespace) {

            try {
                Write-Verbose "Returning all resource types for: $provider"

                $baseUrl = 'https://docs.microsoft.com/azure/templates/'
                $Uri = $baseUrl + $provider + '/allversions'
                Write-Verbose "Checking resource URL: $Uri"

                $response = Invoke-RestMethod -Uri $Uri

                [regex]$regex = '(?<=href=")[^"]+'
                $outItems = New-Object System.Collections.Generic.List[System.Object]
                $outItems += $regex.Matches($response) | ForEach-Object {$_.Value}
                $versionresource = $outItems | Where-Object {$_ -match '([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])).+'}
                Write-Output $versionresource
            } catch {
                Write-Warning "FAILED to return resource types and api versions for provider namespace: $provider."
            }
        } #foreach
    } #PROCESS
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    } #function
}