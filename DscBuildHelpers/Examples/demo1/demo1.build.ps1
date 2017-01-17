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

    ExcludedModules = @() #Module to not test or deploy
    ExcludedFolder  = @('.g*','.hg') #Module to exclude during publishing/discovery

    ConfigurationData       = @{} #Get-DscConfigurationData
    ConfigurationModuleName = 'DSCPULLSRV'
    ConfigurationName       = 'DSCPULLSRV'

    BuildConfigurations = $true #Generate MOFs
    BuildResources      = $true #Test 'em and deploy
    BuildTools          = $true #test 'em and deploy

    #$ModulePath = $null
}

#Invoke-Build @InvokeBuildParams
#Add Build parameters

Import-Module "$PSScriptRoot/../../../DscBuildHelpers" -Force
#Provide Default for DscBuildSourceResources, SourceToolDirectory, DscBuildSourceTools
# change PSModulePath to DscBuildSourceResources + PSHome\Modules + ModulePath
$Env:PSModulePath = $InvokeBuildParams.DscBuildSourceResources + "; $PSHOME\Modules" + $Env:PSModulePath
# Find-ModuleToPublish (Dir in SourceDirectory | ? ! -in $ExcludedModules)
$modulesToPublish = Find-ModuleToPublish -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                                         -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                                         -ExcludedModules @{ModuleName='xStorage';ModuleVersion='2.8.0.0'}

Clear-CachedDscResource -Verbose

#Invoke-DscResourceUnitTest
# This is left out for now, Need to differentiate Unit Test from Integration test
# Unit test aren't pretty for many resources... (Pollute session, need git clone...)


Copy-CurrentDscTools -DscBuildSourceTools $InvokeBuildParams.DscBuildSourceResources `
                     -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools

Test-DscResourceFromModuleInFolderIsValid -ModuleFolder $InvokeBuildParams.DscBuildSourceResources `
                                          -Modules $ModulesToPublish


Assert-DestinationDirectory -DscBuildOutputRoot $InvokeBuildParams.DscBuildOutputRoot `
                            -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                            -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                            -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                            -DscBuildOutputTestResults $InvokeBuildParams.DscBuildOutputTestResults `
                            -BuildConfigurations:$InvokeBuildParams.BuildConfigurations `
                            -BuildResources:$InvokeBuildParams.BuildResources `
                            -BuildTools:$InvokeBuildParams.BuildTools

Invoke-DscConfiguration -ConfigurationModuleName $InvokeBuildParams.ConfigurationModuleName `
                        -ConfigurationName $InvokeBuildParams.ConfigurationName `
                        -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                        -ConfigurationData $InvokeBuildParams.ConfigurationData `
                        -BuildConfigurations:$InvokeBuildParams.BuildConfigurations

Compress-DscResourceModule -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                           -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                           -Modules $modulesToPublish



Publish-DscConfiguration -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                         -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config" `
                         -BuildConfigurations:$InvokeBuildParams.BuildConfigurations

Publish-DscResourceModule -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                          -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"

Publish-DscToolModule -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                      -DscBuildPublishToolsLocation $InvokeBuildParams.DscBuildPublishToolsLocation