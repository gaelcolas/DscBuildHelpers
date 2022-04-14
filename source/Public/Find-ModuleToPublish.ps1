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
        $ExcludedModules = $null,

        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputModules
    )

    $ModulesAvailable = Get-ModuleFromFolder -ModuleFolder $DscBuildSourceResources -ExcludedModules $ExcludedModules

    Foreach ($Module in $ModulesAvailable) {
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