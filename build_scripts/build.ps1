$Global:ErrorActionPreference = 'Stop'
$Global:VerbosePreference = 'SilentlyContinue'

# Prepare NuGet / PSGallery
if (!(Get-PackageProvider | Where-Object { $_.Name -eq 'NuGet' })) {
    Install-PackageProvider -Name NuGet -force | Out-Null
}
Import-PackageProvider -Name NuGet -force | Out-Null

if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

$buildVersion = $env:BUILDVER
$moduleName = 'jtAz'
$manifestPath = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath "jtAz/$moduleName.psd1"

## Update build version in manifest
$manifestContent = Get-Content -Path $manifestPath -Raw
$manifestContent = $manifestContent -replace '<ModuleVersion>', $buildVersion

## Find all of the public functions
$publicFuncFolderPath = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath 'jtAz/functions'
if ((Test-Path -Path $publicFuncFolderPath) -and ($publicFunctionNames = Get-ChildItem -Path $publicFuncFolderPath -Filter '*.ps1' | Select-Object -ExpandProperty BaseName)) {
    $funcStrings = "'$($publicFunctionNames -join "','")'"
} else {
    $funcStrings = $null
}
## Add all public functions to FunctionsToExport attribute
$manifestContent = $manifestContent -replace "'<FunctionsToExport>'", $funcStrings
$manifestContent | Set-Content -Path $manifestPath