BeforeAll {

    $here = $PSScriptRoot

    Import-Module -Name datum
    Import-Module -Name DscBuildHelpers -Force

    $tempPath = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath DscTest
    mkdir -Path $tempPath -Force

    $env:PSModulePath = "$tempPath;$($env:PSModulePath)"

}

AfterAll {

    Remove-Item -Path $tempPath -Recurse -Force

}

Describe 'Initialize-DscResourceMetaInfo' -Tags FunctionalQuality {

    It "'Initialize-DscResourceMetaInfo' does not throw" {
        {
            Initialize-DscResourceMetaInfo -ModulePath $requiredModulesPath -Force -ErrorAction Stop
        } | Should -Not -Throw
    }

    It "'Initialize-DscResourceMetaInfo' throws for non-existing path" {
        {
            Initialize-DscResourceMetaInfo -ModulePath 'C:\NonExistingPath' -Force -ErrorAction Stop
        } | Should -Throw -ExpectedMessage "The module path 'C:\NonExistingPath' does not exist."
    }

    It "'Initialize-DscResourceMetaInfo' throws when no modules are in the path" {
        {
            Initialize-DscResourceMetaInfo -ModulePath $tempPath -Force -ErrorAction Stop
        } | Should -Throw -ExpectedMessage "No modules found in the module path '$tempPath'."
    }

    It "'Initialize-DscResourceMetaInfo' does not throw accessing temp path with 2 modules" {

        dir -Path $here\Assets\DscResources\* -Directory | Copy-Item -Destination $tempPath -Recurse -Force

        {
            Initialize-DscResourceMetaInfo -ModulePath $tempPath -Force -ErrorAction Stop
        } | Should -Not -Throw
    }

    It "'Initialize-DscResourceMetaInfo' gathered the expected data" {

        $param = @{
            TempPath = $tempPath
        }

        Initialize-DscResourceMetaInfo -ModulePath $tempPath -Force -ErrorAction Stop

        InModuleScope DscBuildHelpers -Parameters $param {

            $allDscResourceProperties.Count | Should -Be 10
            $allDscResourcePropertiesTable.Count | Should -Be 10
            $allDscSchemaClasses.Count | Should -Be 9
        }
    }

}
