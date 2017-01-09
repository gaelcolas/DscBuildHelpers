$DscBuildParameters = $null
function Add-DscBuildParameter {
    <#
        .Synopsis
            Adds a parameter to the module scoped DscBuildParameters object.
        .Description
            Adds a parameter to the module scoped DscBuildParameters object.  This object is available to all functions in a build and is built from the parameters to Invoke-DscBuild.
        .Example
            Add-DscBuildParameter -Name ProgramFilesModuleDirectory -value (join-path $env:ProgramFiles 'WindowsPowerShell\Modules')
    #>
    [cmdletbinding()]
    param (
        #Name of the property to add
        [string]
        $Name,
        #Value of the property to add
        [object]
        $Value
    )

    if ($psboundparameters.containskey('WhatIf')) {
        $psboundparameters.Remove('WhatIf') | out-null
    }

    Write-Verbose ''
    Write-Verbose "Adding DscBuildParameter: $Name"
    Write-Verbose "`tWith Value: $Value"
    $script:DscBuildParameters |
            add-member -membertype Noteproperty -force @psboundparameters
    Write-Verbose ''
}
