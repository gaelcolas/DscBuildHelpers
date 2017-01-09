function Test-ModuleVersion {
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [object]
        $InputObject,
        [parameter(Mandatory, position = 0)]
        [string]
        $Destination
    )
    process {
        $DestinationModule = join-path $Destination $InputObject.name

        if (test-path $DestinationModule) {
            $CurrentModuleVersion = Get-ModuleVersion -Path $DestinationModule -asVersion
            $NewModuleVersion = Get-ModuleVersion -Path $InputObject.fullname -asVersion
            if (($CurrentModuleVersion -eq $null) -or ($NewModuleVersion -gt $CurrentModuleVersion)) {
                Write-Verbose "New module version is higher the the currently deployed module.  Replacing it."
                $InputObject
            }
            else {
                Write-Verbose "The current module is the same version or newer than the one in source control.  Not replacing it."
            }
        }
        else {
            Write-Verbose "No existing module at $DestinationModule."
            $InputObject
        }
    }
}