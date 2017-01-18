function Invoke-DscBuild
{
    <#
        .Synopsis
            Starts a build of DSC configurations, resources, and tools.
        .Description
            Starts a build of DSC configurations, resources, and tools.  This command is the global entry point for DSC builds controls the flow of operations.
        .Example
            $BuildParameters = @{
                DscWorkingDirectory = 'd:\gitlab\'
                DscBuildOutputRoot = 'd:\PullServerOutputTest\'
                DscBuildOutputTools = 'd:\ToolsOutputTest\'
            }
            Invoke-DscBuild @BuildParameters
    #>
    [cmdletBinding()]
    [OutputType([void])]
    Param (
        $DscBuildSourceRoot = $(
                if ( $Caller = (Get-PSCallStack)[0].InvocationInfo.MyCommand.Path ) {
                    Split-Path -ErrorAction SilentlyContinue -Parent $Caller
                } 
                else {
                    $PWD.Path
                }
        ),

        $DscBuildOutputRoot           = 'C:\BuildOutput',
        $DscBuildOutputModules        = 'C:\BuildOutput\Modules',
        $DscBuildOutputTools          = 'C:\BuildOutput\Tools',
        $DscBuildOutputConfigurations = 'C:\BuildOutput\Configurations',
        $DscBuildOutputTestResults    = 'C:\BuildOutput\TestResults',

        $DscBuildSourceTools             = (Join-Path -Path $DscBuildSourceRoot -ChildPath '.\DSC_Tooling'),
        $DscBuildSourceScript            = (Join-Path -Path $DscBuildSourceRoot -ChildPath '.\DSC_Script'),
        $DscBuildSourceResources         = (Join-Path -Path $DscBuildSourceRoot -ChildPath '.\DSC_Resources'),
        $DscBuildSourceConfigurationData = (Join-Path -Path $DscBuildSourceRoot -ChildPath '.\DSC_ConfigurationData'),

        [AllowNull()]
        $DscBuildPublishToolsLocation,

        $ExcludedModules = @(@{ModuleName='xStorage';ModuleVersion='2.8.0.0'},'ExcludeMe'), #Module to not test or deploy

        $ConfigurationData       = (Import-PowerShellDataFile `
                                        -Path (Join-Path -Path $DscBuildSourceConfigurationData `
                                                         -ChildPath 'ConfigurationData.psd1')
                                    ),
        $ConfigurationModuleName = 'SimpleConfig',
        $ConfigurationName       = 'SimpleConfig'
    )
    $separation = '#'*70
    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose " STARTING DSC BUILD"
    Write-Verbose ""
    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose ("`tFinding Modules not yet published from $DscBuildSourceResources")

    $modulesToPublish = Find-ModuleToPublish -DscBuildSourceResources $DscBuildSourceResources `
                                             -DscBuildOutputModules $DscBuildOutputModules `
                                             -ExcludedModules $ExcludedModules
    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tTesting PowerShell DSC Resources to Publish"
    Test-DscResourceFromModuleInFolderIsValid -ModuleFolder $DscBuildSourceResources `
                                            -Modules $ModulesToPublish 

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tEnsuring output Directory are created, or create them"
    Assert-BuildDirectory -DscBuildOutputRoot $DscBuildOutputRoot `
                                -DscBuildOutputModules $DscBuildOutputModules `
                                -DscBuildOutputTools $DscBuildOutputTools `
                                -DscBuildOutputConfigurations $DscBuildOutputConfigurations `
                                -DscBuildOutputTestResults $DscBuildOutputTestResults

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tClearing DSC Cache"
    Clear-CachedDscResource

    #Invoke-DscResourceUnitTest
    # This is left out for now, Need to differentiate Unit Test from Integration test
    # Unit test aren't pretty for many resources... (Pollute session, need git clone...)
    
    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tCompiling the MOFs"
    Invoke-DscConfiguration -ConfigurationModuleName $ConfigurationModuleName `
                            -ConfigurationName $ConfigurationName `
                            -DscBuildOutputConfigurations $DscBuildOutputConfigurations `
                            -ConfigurationData $ConfigurationData `
                            -DscBuildSourceResources $DscBuildSourceResources `
                            -DscBuildSourceTools $DscBuildOutputTools `
                            -DscBuildSourceScript $DscBuildSourceScript

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tCopying missing DSC Tooling"
    Copy-CurrentDscTools -DscBuildSourceTools $DscBuildSourceTools `
                        -DscBuildOutputTools $DscBuildOutputTools

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tCompressing Missing module for Pull Server"
    Compress-DscResourceModule -DscBuildSourceResources $DscBuildSourceResources `
                            -DscBuildOutputModules $DscBuildOutputModules `
                            -Modules $modulesToPublish


    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tPublishing MOFs to Pull Server"
    Publish-DscConfiguration -DscBuildOutputConfigurations $DscBuildOutputConfigurations `
                            -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config" 

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose "`tPublishing Compressed Modules to Pull Server"
    Publish-DscResourceModule -DscBuildOutputModules $DscBuildOutputModules `
                            -PullServerWebConfig "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"`
                            -ErrorAction SilentlyContinue
    
    if ($DscBuildPublishToolsLocation) {
        Write-Verbose $separation
        Write-Verbose ""
        Write-Verbose "`tPublishing DSCTools to Tools Publish Location: $DscBuildPublishToolsLocation"
        Publish-DscToolModule -DscBuildOutputTools $DscBuildOutputTools `
                            -DscBuildPublishToolsLocation $DscBuildPublishToolsLocation
    }

    Write-Verbose $separation
    Write-Verbose ""
    Write-Verbose " INVOKE DSC BUILD COMPLETE"
    Write-Verbose ""
    Write-Verbose $separation
    Write-Verbose ""
}