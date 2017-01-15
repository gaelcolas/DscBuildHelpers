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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess")]
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        #Root of your source control check outs or the folder above your Dsc_Configuration, Dsc_Resources, and Dsc_Tools directory.
        [parameter(mandatory)]
        [string]
        $DscWorkingDirectory,

        #Directory containing all the resources to process.  Defaults to a Dsc_Resources directory under the working directory.
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $DscBuildSourceResources,

        #Directory containing all the tools to process.  Defaults to a Dsc_Tooling directory under the working directory.
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceToolDirectory,

        #Root of the location where pull server artifacts (configurations and zipped resources) are published.
        [parameter(mandatory)]
        [string]
        $DscBuildOutputRoot,

        #Destination for any tools that are published.
        [parameter(mandatory)]
        [string]
        $DscBuildOutputTools,

        #Modules to exclude from the resource testing and deployment process.
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ExcludedModules = @(),

        #The configuration data hashtable for the configuration to apply against.
        [parameter(mandatory)]
        [System.Collections.Hashtable]
        $ConfigurationData,

        #The name of the module to load that contains the configuration to run.
        [parameter(mandatory)]
        [string]
        $ConfigurationModuleName,

        #The name of the configuration to run.
        [parameter(mandatory)]
        [string]
        $ConfigurationName,

        #Custom location for the location of the DSC Build Tools modules.
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $DscBuildSourceTools,

        #This switch is used to indicate that configuration documents should be generated and deployed.
        [parameter()]
        [switch]
        $Configuration,

        #This switch is used to indicate that custom resources should be tested and deployed.
        [parameter()]
        [switch]
        $Resource,

        #This switch is used to indicate that the custom tools should be tested and deployed.
        [parameter()]
        [switch]
        $Tools,

        # Paths that should be in the PSModulePath during test execution.  $DscBuildSourceResources and $pshome\Modules are automatically included in this list.
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ModulePath,

        #Skip DSC resources Unit test (quicker but more fragile)
        [switch]
        $SkipDSCResourcesUnitTest
    )

    $script:DscBuildParameters = new-object PSObject -property $PSBoundParameters
    if (-not $PSBoundParameters.ContainsKey('DscBuildSourceResources')) {
        Add-DscBuildParameter -Name DscBuildSourceResources -value (Join-Path $DscWorkingDirectory 'Dsc_Resources')
    }
    if (-not $PSBoundParameters.ContainsKey('SourceToolDirectory')) {
        Add-DscBuildParameter -Name SourceToolDirectory -value (Join-Path $DscWorkingDirectory 'Dsc_Tooling')
    }
    if (-not $PSBoundParameters.ContainsKey('DscBuildSourceTools')) {
        Add-DscBuildParameter -Name DscBuildSourceTools -value (join-path $env:ProgramFiles 'WindowsPowerShell\Modules')
    }

    $ParametersToPass = @{}
    foreach ($key in ('Whatif', 'Verbose', 'Debug'))
    {
        if ($PSBoundParameters.ContainsKey($key)) {
            $ParametersToPass[$key] = $PSBoundParameters[$key]
        }
    }

    $originalPSModulePath = $env:PSModulePath

    try
    {
        $dirPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DscBuildSourceResources)

        $modulePaths = @(
            $dirPath
            Join-Path $pshome Modules
            $ModulePath
        )

        $env:PSModulePath = $modulePaths -join ';'
        if ( $Resource -or -not ($Tools -or $Configuration)) {
            $modulesToPublish = Find-ModuleToPublish @ParametersToPass
        }

        Add-DscBuildParameter -Name ModulesToPublish -Value $modulesToPublish
        
        Clear-CachedDscResource @ParametersToPass

        if(!$SkipDSCResourcesUnitTest) {
            #The Unit tests are not consitent, and some cannot be run twice (don't cleanup the session)
            #Also, the current implementation Invoke-Pester on the whole resource, but Integration tests
            #can't be run like so
            Invoke-DscResourceUnitTest @ParametersToPass
        }

        Copy-CurrentDscTools @ParametersToPass

        Test-DscResourceIsValid @ParametersToPass

        Assert-DestinationDirectory @ParametersToPass

        Invoke-DscConfiguration @ParametersToPass

        Compress-DscResourceModule @ParametersToPass
        Publish-DscToolModule @ParametersToPass
        Publish-DscResourceModule @ParametersToPass
        Publish-DscConfiguration @ParametersToPass
    }
    finally
    {
        $env:PSModulePath = $originalPSModulePath
    }
}
