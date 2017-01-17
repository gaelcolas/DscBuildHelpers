function Find-ModuleToPublish {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $DscBuildSourceResources,
        
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        $ExcludedModules = $ExcludedModules,

        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputModules
    )
    Write-Debug -Message "Replacing Module path with $DscBuildSourceResources"
    $OldPSModulePath = $env:PSModulePath
    $env:PSModulePath = $DscBuildSourceResources
    $ModulesAvailable = Get-Module -Refresh -ListAvailable | Where-Object {
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

    Foreach ($Module in $ModulesAvailable) {
        if ($Module.Name -notin $ExcludedModules) {
            $publishTargetZip =  [System.IO.Path]::Combine(
                                                $DscBuildOutputModules,
                                                "$($module.Name)_$($module.version).zip"
                                                )
            $publishTargetZipCheckSum =  [System.IO.Path]::Combine(
                                                $DscBuildOutputModules,
                                                "$($module.Name)_$($module.version).zip.checksum"
                                                )

            $zipExists      = Test-Path -Path $publishTargetZip
            $checksumExists = Test-Path -Path $publishTargetZipCheckSum

            if (-not ($zipExists -and $checksumExists))
            {
                Write-Debug "ZipExists = $zipExists; CheckSum exists = $checksumExists"
                Write-Verbose -Message "Adding $($Module.Name)_$($Module.Version) to the Modules To Publish"
                Write-Output -inputObject $Module
            }
            else {
                Write-Verbose -Message "$($Module.Name) does not need to be published"
            }
        }
    }
    $env:PSModulePath = $OldPSModulePath

}