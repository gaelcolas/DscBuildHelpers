function Compress-DscResourceModule
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DscBuildOutputModules,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [PSModuleInfo[]]
        $Modules
    )

    begin
    {
        if (-not (Test-Path -Path $DscBuildOutputModules))
        {
            mkdir -Path $DscBuildOutputModules -Force
        }
    }

    process
    {
        foreach ($module in $Modules)
        {
            if ($PSCmdlet.ShouldProcess("Compress $Module $($Module.Version) from $(Split-Path -Parent $Module.Path) to $DscBuildOutputModules"))
            {
                Write-Verbose "Publishing Module $(Split-Path -Parent $Module.Path) to $DscBuildOutputModules"
                $destinationPath = Join-Path -Path $DscBuildOutputModules -ChildPath "$($module.Name)_$($module.Version).zip"
                Compress-Archive -Path "$($module.ModuleBase)\*" -DestinationPath $destinationPath

                (Get-FileHash -Path $destinationPath).Hash | Set-Content -Path "$destinationPath.checksum" -NoNewline
            }
        }
    }
}
