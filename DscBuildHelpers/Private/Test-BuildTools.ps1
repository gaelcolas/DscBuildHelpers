
function Test-BuildTools {
     <#
        .Synopsis
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing tools.
        .Description
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing tools.  This is used by functions in the module to determine whether a particular block needs to execute.
        .Example
            if (Test-BuildTools) { do something...}
    #>
    [cmdletbinding()]
    param ()
    $IsBuild = ( $script:DscBuildParameters.Tools -or
                (-not ($script:DscBuildParameters.Configuration -or $script:DscBuildParameters.Resource) ) )
    Write-Verbose ''
    Write-Verbose "Is a Tools Build - $IsBuild"
    Write-Verbose ''
    return $IsBuild
}