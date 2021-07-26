Set-StrictMode -Version Latest

# Get public and private function definition files.

$functions = Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -ErrorAction SilentlyContinue

# Dot source the files.
foreach ($import in $functions) {
    try {
        Write-Verbose "Importing $($import.FullName)"        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

## Export all of the functions making them available to the user
foreach ($file in $functions) {
    Export-ModuleMember -Function $file.BaseName
}