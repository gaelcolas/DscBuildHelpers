#Requires -Modules  xPSDesiredStateConfiguration
function Compress-DscResourceModule {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            #Mandatory
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

    begin {
        if (!(Test-Path $DscBuildOutputModules)) {
            mkdir $DscBuildOutputModules -Force
        }
    }
    Process {
        Foreach ($Module in $Modules) {
            if (
                 $pscmdlet.shouldprocess(
                    "Compress $Module $($Module.Version) from $(Split-Path -parent $Module.Path) to $DscBuildOutputModules"
                 )
                )
            {
                Write-Verbose "Publishing Module $(Split-Path -parent $Module.Path) to $DscBuildOutputModules"
                $Module |  xPSDesiredStateConfiguration\Publish-ModuleToPullServer -ModuleBase (Split-Path -parent $Module.Path) `
                                                     -OutputFolderPath $DscBuildOutputModules
            }
        }
    }
}
