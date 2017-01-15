function Test-DscResourceIsValid {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        $DscBuildSourceResources,
        
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        $ModulesToPublish
    )


    if ($pscmdlet.shouldprocess("modules from $DscBuildSourceResources")) {
        if ($ModulesToPublish.Count -gt 0)
        {
            #$AllResources = Get-DscResource | Where-Object {$_.ImplementedAs -like 'PowerShell'}
            Get-ChildItem -Path $DscBuildSourceResources -Directory |
                ForEach-Object { Get-Module -ListAvailable -FullyQualifiedName $_.FullName -ErrorAction SilentlyContinue } |
                  Where-Object Name -in $ModulesToPublish |
                    Assert-DscModuleResourceIsValid
        }
    }
}