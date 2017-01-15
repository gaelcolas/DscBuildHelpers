function Get-DscResourceForModule
{
    [cmdletbinding()]
    param (
        [PSModuleInfo]
        $Module,
        $AllResources = $(Get-DscResource)
    )

    Write-Verbose "Retrieving all resources and filtering for $Module."

    $ResourcesInModule = $AllResources |
        Where-Object {
            Write-Verbose "`tChecking for $($_.name) in $($Module.Name) version $($Module.Version)."
            $_.moduleName -eq $Module.Name -and
            $_.version -eq $Module.Version
        }
    
    if ($ResourcesInModule.count -eq 0)
    {
        Write-Verbose "${Module.Name} does not contain any testable resources."
    }
    else {
        Write-Verbose -Message ("`tResources found in {0}: {1}" -f $Module.Name,($ResourcesInModule.Name -join '; '))
    }

    # We still want to deploy modules that have no testeable resources; they may contain
    # resources that are implemented as binary, or with PowerShell Classes in v5, etc.
    #$script:DscBuildParameters.TestedModules += $InputObject.FullName

    $ResourcesInModule
}