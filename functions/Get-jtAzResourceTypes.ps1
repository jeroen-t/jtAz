function Get-jtAzResourceTypes {
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$providerNamespace
    )
    BEGIN {
        Write-Verbose "Starting: $($MyInvocation.MyCommand)"
    }
    PROCESS {
        $baseUrl = 'https://docs.microsoft.com/azure/templates/'
        $Uri = $baseUrl + '/'+ $providerNamespace + '/allversions'
        Write-Verbose "Resource URL: $Uri"

        $response = Invoke-RestMethod -Uri $Uri
        # todo: error handling

        [regex]$regex = '(?<=href=")[^"]+'
        $outItems = New-Object System.Collections.Generic.List[System.Object]
        $outItems += $regex.Matches($response) | ForEach-Object {$_.Value}
        $versionresource = $outItems | Where-Object {$_ -match '([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])).+'}
        Write-Output $versionresource
    }
    END {
        Write-Verbose "Ending: $($MyInvocation.MyCommand)"
    }
}

# Get-jtAzResourceTypes -providerNamespace microsoft.sql # | Out-File C:\Temp\letsregex.html