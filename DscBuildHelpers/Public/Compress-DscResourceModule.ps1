function Compress-DscResourceModule {
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
        [String]
        $DscBuildOutputModules,

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowNull()]
        [PSmoduleInfo[]]
        $Modules
    )

    Process {
        Foreach ($Module in $Modules) {
            if (
                 $pscmdlet.shouldprocess(
                    "Compress $Module $($Module.Version) from $DscBuildSourceResources to $DscBuildOutputModules"
                 )
                )
            {
                $Module | Publish-ModuleToPullServer -ModuleBase (Split-Path -parent $Module.Path) `
                                                     -OutputFolderPath $DscBuildOutputModules
            }
        }
    }
}
