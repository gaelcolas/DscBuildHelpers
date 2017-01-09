function Test-DscResourceIsValid {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param ()

    Add-DscBuildParameter -Name TestedModules -value @()

    if ( Test-BuildResource ) {
        if ($pscmdlet.shouldprocess("modules from $($script:DscBuildParameters.SourceResourceDirectory)")) {
            if ($script:DscBuildParameters.ModulesToPublish.Count -gt 0)
            {
                #$AllResources = Get-DscResource | Where-Object {$_.ImplementedAs -like 'PowerShell'}

                Get-ChildItem -Path $script:DscBuildParameters.SourceResourceDirectory -Directory |
                 Where-Object Name -in $script:DscBuildParameters.ModulesToPublish |
                  Assert-DscModuleResourceIsValid
            }
        }
    }
}