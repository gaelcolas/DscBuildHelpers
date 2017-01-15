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

    ConfigurationData           = $null #Get-DscConfigurationData
    ConfigurationDataModuleName = 'DSCPULLSRV'
    ConfigurationName           = 'DSCPULLSRV'

    BuildConfigurations = $true #Generate MOFs
    BuildResources      = $true #Test 'em and deploy
    BuildTools          = $true #test 'em and deploy

    #$ModulePath = $null
}

#Invoke-Build @InvokeBuildParams
#Add Build parameters

Import-Module -Name "$PSScriptRoot/../../../DscBuildHelpers"
#Provide Default for DscBuildSourceResources, SourceToolDirectory, DscBuildSourceTools
# change PSModulePath to DscBuildSourceResources + PSHome\Modules + ModulePath
$Env:PSModulePath = $InvokeBuildParams.DscBuildSourceResources + "; $PSHOME\Modules" + $Env:PSModulePath
# Find-ModuleToPublish (Dir in SourceDirectory | ? ! -in $ExcludedModules)
$modulesToPublish = Find-ModuleToPublish -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules -ExcludedFolder 'ExcludeMe'
# Clear-CachedDscResource
Clear-CachedDscResource -Verbose

#Invoke-DscResourceUnitTest
# This is left out for now, Need to differentiate Unit Test from Integration test
# Unit test aren't pretty for many resources... (Pollute session, need git clone...)

#Copy-CurrentDscTools
Copy-CurrentDscTools -SourceToolDirectory $InvokeBuildParams.DscBuildSourceResources `
                     -DscBuildSourceTools $InvokeBuildParams.DscBuildOutputTools

Test-DscResourceIsValid -DscBuildSourceResources $DscBuildSourceResources -ModulesToPublish $ModulesToPublish

#Assert-DestinationDirectory @ParametersToPass
Assert-DestinationDirectory -DscBuildOutputRoot $InvokeBuildParams.DscBuildOutputRoot `
                            -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                            -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                            -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                            -DscBuildOutputTestResults $InvokeBuildParams.DscBuildOutputTestResults `
                            -BuildConfigurations:$InvokeBuildParams.BuildConfigurations `
                            -BuildResources:$InvokeBuildParams.BuildResources `
                            -BuildTools:$InvokeBuildParams.BuildTools `

Invoke-DscConfiguration -ConfigurationModuleName $InvokeBuildParams.ConfigurationModuleName `
                        -ConfigurationName $InvokeBuildParams.ConfigurationName `
                        -DscBuildOutputConfigurations $InvokeBuildParams.DscBuildOutputConfigurations `
                        -ConfigurationData $InvokeBuildParams.ConfigurationData `
                        -BuildConfigurations:$InvokeBuildParams.BuildConfigurations

Compress-DscResourceModule -DscBuildSourceResources $InvokeBuildParams.DscBuildSourceResources `
                           -DscBuildOutputModules $InvokeBuildParams.DscBuildOutputModules `
                           -TestedModules $modulesToPublish


#Publish-DscToolModule @ParametersToPass
Publish-DscConfiguration -DscBuildOutputConfiguration $InvokeBuildParams.DscBuildOutputConfiguration `
                         -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config" `
                         -BuildConfigurations $InvokeBuildParams.BuildConfigurations

Publish-DscResourceModule -DscBuildOutputResources $InvokeBuildParams.DscBuildOutputResources `
                          -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config" `
                          -BuildResources:$InvokeBuildParams.BuildResources `
                          -ErrorAction SilentlyContinue

Publish-DscToolModule -DscBuildOutputTools $InvokeBuildParams.DscBuildOutputTools `
                      -DscBuildPublishToolsLocation $InvokeBuildParams.DscBuildPublishToolsLocation