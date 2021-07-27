function Get-jtAzProviderNamespace {
<#
.SYNOPSIS
    Returns all the provider namespaces found on https://docs.microsoft.com/en-us/azure/templates/

.DESCRIPTION
    Get-jtAzProviderNamespace is a function that returns the all the provider namespaces found at https://docs.microsoft.com/en-us/azure/templates/.

.PARAMETER Name
    The provider namespace you are searching for. Can be any string.

.EXAMPLE
     Get-jtAzProviderNamespace

.EXAMPLE
     Get-jtAzProviderNamespace -Name sql

.INPUTS
    String

.OUTPUTS
    String

.NOTES
    Author:  Jeroen Trimbach
    Website: https://jeroentrimbach.com
#>
    param (
        [Parameter(Position=0,Mandatory=$false)]
        [string]$Name
    )
    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand)"
    }
    PROCESS {
        try {
            $response = Invoke-RestMethod -Uri https://docs.microsoft.com/en-us/azure/templates/breadcrumb/toc.json
            $items = $response.items.children.children.children |
                ForEach-Object {
                    $words = $_.href.replace('/azure/templates/','').Split('/')
                    $words[0]
            }
            if ($PSBoundParameters.ContainsKey('Name')) {
                Write-Output $items |
                    Select-Object -Unique |
                    Where-object {$_ -match $Name} |
                    Sort-Object
            } else {
                Write-Output $items |
                    Select-Object -Unique |
                    Sort-Object
            }
        } catch {
            Write-Warning "FAILED to return provider namespace(s)"
        }
    }
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    }
}