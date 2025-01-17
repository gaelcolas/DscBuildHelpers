BeforeAll {

    $here = $PSScriptRoot

    Import-Module -Name datum
    Import-Module -Name DscBuildHelpers -Force

}

Describe 'Initialize-DscResourceMetaInfo' -Tags FunctionalQuality {

    It "'Initialize-DscResourceMetaInfo' does not throw" {

        {
            Initialize-DscResourceMetaInfo -ModulePath $requiredModulesPath -Force -ErrorAction Stop
        } | Should -Not -Throw
    }

}
