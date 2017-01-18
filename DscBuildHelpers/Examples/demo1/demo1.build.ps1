rm -Force -Recurse C:\BuildOutput
<#
C:\BuildOutput
C:\BuildOutput\Modules
C:\BuildOutput\Tools
C:\BuildOutput\Configuration
C:\BuildOutput\Tests


C:\BuildSource
C:\BuildSource\DSC_Tooling
C:\BuildSource\DSC_Script
C:\BuildSource\DSC_Resources
C:\BuildSource\DSC_ConfigurationData
#>
#$PSScriptRoot = 'C:\src\DscBuildHelpers\DscBuildHelpers\Examples\demo1'
$InvokeBuildParams = @{
    DscWorkingDirectory = $PSScriptRoot

    DscBuildOutputRoot           = 'C:\BuildOutput'
    DscBuildOutputModules        = 'C:\BuildOutput\Modules'
    DscBuildOutputTools          = 'C:\BuildOutput\Tools'
    DscBuildOutputConfigurations = 'C:\BuildOutput\Configurations'
    DscBuildOutputTestResults    = 'C:\BuildOutput\TestResults'

    DscBuildSourceTools             = Join-Path -Path $PSScriptRoot -ChildPath '.\DSC_Tooling'
    DscBuildSourceScript            = Join-Path -Path $PSScriptRoot -ChildPath '.\DSC_Script'
    DscBuildSourceResources         = Join-Path -Path $PSScriptRoot -ChildPath '.\DSC_Resources'
    DscBuildSourceConfigurationData = Join-Path -Path $PSScriptRoot -ChildPath '.\DSC_ConfigurationData'

    DscBuildPublishToolsLocation = Join-Path -Path $PSHome -ChildPath Modules

    ExcludedModules = @(@{ModuleName='xStorage';ModuleVersion='2.8.0.0'},'ExcludeMe') #Module to not test or deploy

    ConfigurationData       = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath '.\DSC_ConfigurationData\ConfigurationData.psd1')
    ConfigurationModuleName = 'SimpleConfig'
    ConfigurationName       = 'SimpleConfig'
}

#Invoke-Build @InvokeBuildParams

Import-Module "$PSScriptRoot/../../../DscBuildHelpers" -Force

$modulesToPublish = Find-ModuleToPublish -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                                         -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                                         -ExcludedModules $InvokeBuildParams.ExcludedModules

Assert-BuildDirectory -DscBuildOutputRoot $InvokeBuildParams.DscBuildOutputRoot `
                            -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                            -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                            -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                            -DscBuildOutputTestResults $InvokeBuildParams.DscBuildOutputTestResults


Clear-CachedDscResource

#Invoke-DscResourceUnitTest
# This is left out for now, Need to differentiate Unit Test from Integration test
# Unit test aren't pretty for many resources... (Pollute session, need git clone...)

Copy-CurrentDscTools -DscBuildSourceTools $InvokeBuildParams.DscBuildSourceTools `
                     -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools -Verbose

Test-DscResourceFromModuleInFolderIsValid -ModuleFolder $InvokeBuildParams.DscBuildSourceResources `
                                          -Modules $ModulesToPublish 


$Env:PSModulePath = $InvokeBuildParams.DscBuildSourceResources + ";$PSHOME\Modules;" + $Env:PSModulePath
Invoke-DscConfiguration -ConfigurationModuleName $InvokeBuildParams.ConfigurationModuleName `
                        -ConfigurationName $InvokeBuildParams.ConfigurationName `
                        -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                        -ConfigurationData $InvokeBuildParams.ConfigurationData `
                        -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                        -DscBuildSourceTools $InvokeBuildParams.DscBuildOutputTools `
                        -DscBuildSourceScript $InvokeBuildParams.DscBuildSourceScript

Compress-DscResourceModule -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                           -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                           -Modules $modulesToPublish



Publish-DscConfiguration -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                         -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config" 


Publish-DscResourceModule -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                          -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"`
                         -ErrorAction SilentlyContinue

Publish-DscToolModule -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                      -DscBuildPublishToolsLocation $InvokeBuildParams.DscBuildPublishToolsLocation
