@{
    RootModule        = 'jtAz.psm1'
    ModuleVersion     = '<ModuleVersion>'
    GUID              = 'd49a8cd6-af6c-40d0-9c7d-4c9bfcfe39b1'
    Author            = 'Jeroen Trimbach'
    CompanyName       = 'n/a'
    Description       = 'The module jtAz contains functions that will return the Azure ARM and/or Bicep templates for specified resources from https://docs.microsoft.com/en-us/azure/templates/'
    PowerShellVersion = '6.0'
    FunctionsToExport = @('<FunctionsToExport>')
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries:
            Tags = @('PowerShell','Azure','ARM','Bicep','Resource','Manager')

            # A URL to the license for this module
            LicenseUri = 'https://github.com/jeroen-t/jtAz/blob/aabae9103621ae1f27fc81d87f7ca2b64ee49386/LICENSE'

            # A URL to the main website for this project
            ProjectUri = 'https://github.com/jeroen-t/jtAz'
        }
    }
}