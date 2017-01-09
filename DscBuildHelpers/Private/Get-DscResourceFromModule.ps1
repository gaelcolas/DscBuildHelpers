function Get-DscResourceForModule
{
    [cmdletbinding()]
    param ($InputObject)

    $Name = $inputobject.Name
    Write-Verbose "Retrieving all resources and filtering for $Name."

    $ResourcesInModule = $AllResources |
        Where-Object {
            Write-Verbose "`tChecking for $($_.name) in $name."
            $_.module -like $name
        } |
        ForEach-Object {
            Write-Verbose "`t$Name contains $($_.Name)."
            $_
        }

    if ($ResourcesInModule.count -eq 0)
    {
        Write-Verbose "$Name does not contain any testable resources."
    }

    # We still want to deploy modules that have no testeable resources; they may contain
    # resources that are implemented as binary, or with PowerShell Classes in v5, etc.
    $script:DscBuildParameters.TestedModules += $InputObject.FullName

    $ResourcesInModule
}