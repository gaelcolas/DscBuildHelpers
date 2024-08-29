function Get-ModuleFromFolder
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo[]])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]]
        $ModuleFolder,

        [Parameter()]
        [AllowNull()]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        $ExcludedModules
    )

    begin
    {
        $allModulesInFolder = @()
    }

    process
    {
        foreach ($folder in $ModuleFolder)
        {
            Write-Debug -Message "Replacing Module path with $folder"
            $oldPSModulePath = $env:PSModulePath
            $env:PSModulePath = $folder
            Write-Debug -Message 'Discovering modules from folder'
            $allModulesInFolder += Get-Module -Refresh -ListAvailable
            Write-Debug -Message 'Reverting PSModulePath'
            $env:PSModulePath = $oldPSModulePath
        }
    }

    end
    {

        $allModulesInFolder | Where-Object {
            $source = $_
            Write-Debug -Message "Checking if module '$source' is sxcluded."
            $isExcluded = foreach ($excludedModule in $ExcludedModules)
            {
                Write-Debug "`t Excluded module '$ExcludedModule'"
                if (($excludedModule.Name -and $excludedModule.Name -eq $source.Name) -and
                    (
                        (-not $excludedModule.Version -and
                        -not $excludedModule.Guid -and
                        -not $excludedModule.MaximumVersion -and
                        -not $excludedModule.RequiredVersion ) -or
                        ($excludedModule.Version -and $excludedModule.Version -eq $source.Version) -or
                        ($excludedModule.Guid -and $excludedModule.Guid -ne $source.Guid) -or
                        ($excludedModule.MaximumVersion -and $excludedModule.MaximumVersion -ge $source.Version) -or
                        ($excludedModule.RequiredVersion -and $excludedModule.RequiredVersion -eq $source.Version)
                    )
                )
                {
                    Write-Debug ('Skipping {0} {1} {2}' -f $source.Name, $source.Version, $source.Guid)
                    return $false
                }
            }
            if (-not $isExcluded)
            {
                return $true
            }
        }
    }

}
