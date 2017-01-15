$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here/../../*/$sut" #for files in Public\Private folders, called from the tests folder

$DemoPath = "$PSScriptRoot\..\..\examples\Demo1"

function Get-DscResourceVersion { param($Path, $source, [switch]$asVersion) }

function Test-BuildResource {}


Describe 'Find-ModuleToPublish' {

  Context 'General context'   {

    Mock Test-BuildResource -MockWith {return $true}
    $demo1 = @{
        DscBuildSourceResources = Join-Path -Path $DemoPath -ChildPath DSC_Resources
    }
    It 'runs without errors' {
        { Find-ModuleToPublish -DscBuildSourceResources $demo1.DscBuildSourceResources -DscBuildOutputRoot Test:\ -ExcludedModules ExcludeMe } | Should Not Throw
    }

    It 'throws when it does something wrong' {
      { Find-ModuleToPublish -DscBuildSourceResources $null } | Should Throw
    }
  }
}