function Compress-DscResourceModule {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DscBuildOutputModules,

        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [psmoduleinfo[]]
        $Modules
    )

    begin {
        if (-not (Test-Path -Path $DscBuildOutputModules)) {
            mkdir -Path $DscBuildOutputModules -Force
        }
    }
    Process {
        Foreach ($module in $Modules) {
            if ($PSCmdlet.ShouldProcess("Compress $Module $($Module.Version) from $(Split-Path -parent $Module.Path) to $DscBuildOutputModules")) {
                Write-Verbose "Publishing Module $(Split-Path -parent $Module.Path) to $DscBuildOutputModules"
                $destinationPath = Join-Path -Path $DscBuildOutputModules -ChildPath "$($module.Name)_$($module.Version).zip"
                Compress-Archive -Path "$($module.ModuleBase)\*" -DestinationPath $destinationPath
                
                (Get-FileHash -Path $destinationPath).Hash | Set-Content -Path "$destinationPath.checksum"
            }
        }
    }
}
