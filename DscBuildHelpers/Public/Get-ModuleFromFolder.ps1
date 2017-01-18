function Get-ModuleFromFolder {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSModuleInfo[]')]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [io.DirectoryInfo[]]
        $ModuleFolder,
        
        [AllowNull()]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        $ExcludedModules = $null
    )

    Begin {
        $AllModulesInFolder = @()
    }

    Process {
        foreach ($Folder in $ModuleFolder) {
            Write-Debug -Message "Replacing Module path with $Folder"
            $OldPSModulePath = $env:PSModulePath
            $env:PSModulePath = $Folder
            Write-Debug -Message "Discovering modules from folder"
            $AllModulesInFolder += Get-Module -Refresh -ListAvailable
            Write-Debug -Message "Reverting PSModulePath"
            $env:PSModulePath = $OldPSModulePath
        }
    }

    End {

        $AllModulesInFolder | Where-Object {
            $source = $_
            Write-Debug -message "Checking if Module $source is Excluded."
            $isExcluded = foreach ($ExcludedModule in $ExcludedModules){
                Write-Debug "`t Excluded Module $ExcludedModule"
                if ( ($ExcludedModule.Name -and $ExcludedModule.Name -eq $source.Name) -and 
                    (
                        ( !$ExcludedModule.Version -and 
                          !$ExcludedModule.Guid -and 
                          !$ExcludedModule.MaximumVersion -and 
                          !$ExcludedModule.RequiredVersion ) -or
                        ($ExcludedModule.Version -and $ExcludedModule.Version -eq $source.Version) -or
                        ($ExcludedModule.Guid -and $ExcludedModule.Guid -ne $source.Guid) -or
                        ($ExcludedModule.MaximumVersion -and $ExcludedModule.MaximumVersion -ge $source.Version) -or
                        ($ExcludedModule.RequiredVersion -and $ExcludedModule.RequiredVersion -eq $source.Version)
                    )
                   ) {
                    Write-Debug ('Skipping {0} {1} {2}' -f $source.Name,$source.Version,$source.Guid)
                    return $false
                }
            }
            if(!$isExcluded) {
                return $true
            }
        }
    }
    
}