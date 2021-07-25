function Get-jtAzResourceTypes {
<#
.SYNOPSIS
    Returns all the resource types and api versions for a given provider namespace.

.DESCRIPTION
    Get-jtAzResourceTypes is a function that returns the all the resource types and api versions for the given provider namespace found at https://docs.microsoft.com/en-us/azure/templates/.

.PARAMETER providerNamespace
    The provider namespace

.EXAMPLE
     Get-jtAzTemplate -providerNamespace 'microsoft.sql'

.INPUTS
    String

.OUTPUTS
    object[]

.NOTES
    Author:  Jeroen Trimbach
    Website: https://jeroentrimbach.com
#>
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$providerNamespace
    )
    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand)"
    }
    PROCESS {
        try {
            $baseUrl = 'https://docs.microsoft.com/azure/templates/'
            $Uri = $baseUrl + $providerNamespace + '/allversions'
            Write-Verbose "Resource URL: $Uri"

            $response = Invoke-RestMethod -Uri $Uri
            # todo: error handling

            [regex]$regex = '(?<=href=")[^"]+'
            $outItems = New-Object System.Collections.Generic.List[System.Object]
            $outItems += $regex.Matches($response) | ForEach-Object {$_.Value}
            $versionresource = $outItems | Where-Object {$_ -match '([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])).+'}
            Write-Output $versionresource
        } catch {
            Write-Warning "FAILED to return resource types and api versions for provider namespace: $providerNamespace."
        }
    }
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    }
}