
function Test-BuildResource {
    <#
        .Synopsis
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing resources.
        .Description
            Checks to see if a build started with Invoke-DscBuild will be processing new or existing resources.  This is used by functions in the module to determine whether a particular block needs to execute.
        .Example
            if (Test-BuildResource) { do something...}
    #>
    [cmdletbinding()]
    param ()
    $IsBuild = ( $script:DscBuildParameters.Resource -or
                (-not ($script:DscBuildParameters.Tools -or $script:DscBuildParameters.Configuration) ) )
    Write-Verbose ''
    Write-Verbose "Is a Resource Build - $IsBuild"
    Write-Verbose ''
    return $IsBuild
}