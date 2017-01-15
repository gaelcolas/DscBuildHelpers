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
            Mandatory
        )]
        [ValidatedNotNullOrEmpty()]
        $TestedModules
    )

    if ( Test-BuildResource )  {
        if ($pscmdlet.shouldprocess("from $DscBuildSourceResources to $DscBuildOutputModules")) {

            if ($TestedModules.Count -gt 0)
            {
                foreach ($source in $TestedModules) {
                    Write-Verbose -Message "Compressing tested modules: "
                    Write-Verbose -Message "`t$module"

                    $ModuleVersion = '0.0.1'
                    $moduleName = Split-Path $source -Leaf
                    $modulepsd1 = (Join-Path $source "$moduleName.psd1")
                    $modulepsm1 = (Join-Path $source "$moduleName.psm1")

                    if ( Test-Path -Path $modulepsd1 -ErrorAction SilentlyContinue ){
                        $ModuleVersion = Get-Metadata -Path $modulepsd1 -PropertyName 'ModuleVersion'
                        Write-Verbose -Message "`tVersion = $moduleVersion;"
                        Write-Verbose -Message "`tModuleBase = $source"
                        Write-Verbose -Message ''
                        @{
                            Name = $moduleName
                            ModuleBase = $source
                            Version = $moduleVersion
                            OutputFolderPath = $DscBuildOutputModules
                        } | Publish-ModuleToPullServer
                    }
                    elseif(
                            !(Test-Path -Path $modulepsd1) -and
                             (Test-Path -Path $modulepsm1)
                          ) {
                            Write-Debug "`tNo PSD1 file found. Using default version $ModuleVersion"
                            Write-Verbose -Message "`tVersion = $moduleVersion (no $moduleName.psd1 found);"
                            Write-Verbose -Message "`tModuleBase = $source"
                            Write-Verbose -Message ''
                            @{
                                Name = $moduleName
                                ModuleBase = $source
                                Version = $moduleVersion
                                OutputFolderPath = $DscBuildOutputModules
                            } | Publish-ModuleToPullServer
                    }
                    else {
                        $ModuleVersionFolders = Get-ChildItem -Path $source -Directory | Where-Object { 
                            $_.Name -as [Version]
                        }
                        foreach ($moduleVersionFolder in $ModuleVersionFolders) {
                            Write-Verbose -Message "`tVersion = $($moduleVersionFolder.Name)"
                            Write-Verbose -Message "`tModuleBase = $($moduleVersionFolder.FullName)"
                            Write-Verbose -Message ''
                            @{
                                Name = $moduleName
                                ModuleBase = $moduleVersionFolder.FullName
                                Version = $moduleVersionFolder.Name
                                OutputFolderPath = $DscBuildOutputModules
                            } | Publish-ModuleToPullServer
                        }
                    }
                }
            }
        }
    }
}
