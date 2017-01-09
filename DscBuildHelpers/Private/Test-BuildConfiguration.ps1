
function Test-BuildConfiguration {
     <#
        .Synopsis
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing configurations.
        .Description
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing configurations.  This is used by functions in the module to determine whether a particular block needs to execute.
        .Example
            if (Test-BuildConfiguration) { do something...}
    #>
    [cmdletbinding()]
    param ()
    $IsBuild = ( $script:DscBuildParameters.Configuration -or
                (-not ($script:DscBuildParameters.Tools -or $script:DscBuildParameters.Resource) ) )
    Write-Verbose ''
    Write-Verbose "Is a Configuration Build - $IsBuild"
    Write-Verbose ''
    return $IsBuild
}