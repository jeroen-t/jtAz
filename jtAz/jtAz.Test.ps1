Install-Module -Name PSScriptAnalyzer -Force

describe 'Module-level tests' {
    it 'the module imports successfully' {
        { Import-Module ".\jtAz\jtAz.psm1" -ErrorAction Stop } | should -not throw
    }

    it 'the module has an associated manifest' {
        Test-Path ".\jtAz\jtAz.psd1" | should -Be $true
    }

    it 'passes all default PSScriptAnalyzer rules' {
        Invoke-ScriptAnalyzer -Path ".\jtAz\jtAz.psm1" | should -BeNullOrEmpty
    }
}
