function Initialize-DscResourceMetaInfo
{
    param (
        [Parameter(Mandatory)]
        [string]
        $ModulePath,

        [Parameter()]
        [switch]
        $ReturnAllProperties,

        [Parameter()]
        [switch]
        $Force
    )

    if ($script:allDscResourcePropertiesTable -and -not $Force)
    {
        return
    }

    $allModules = Get-ModuleFromFolder -ModuleFolder $ModulePath
    $allDscResource = Get-DscResourceFromModuleInFolder -ModuleFolder $ModulePath -Modules $allModules
    $modulesWithDscResources = $allDscResource | Select-Object -ExpandProperty ModuleName -Unique
    $modulesWithDscResources = $allModules | Where-Object Name -In $modulesWithDscResources

    $script:allDscResourcePropertiesTable = @{}

    $script:allDscResourceProperties = foreach ($dscResource in $allDscResource)
    {
        $cimProperties = if ($ReturnAllProperties)
        {
            Get-DscResourceProperty -ModuleInfo ($modulesWithDscResources | Where-Object Name -EQ $dscResource.ModuleName) -ResourceName $dscResource.Name
        }
        else
        {
            Get-DscResourceProperty -ModuleInfo ($modulesWithDscResources |
            Where-Object Name -EQ $dscResource.ModuleName) -ResourceName $dscResource.Name |
            Where-Object {
                $_.TypeConstraint -like 'MSFT_*' -and $_.TypeConstraint -notin 'MSFT_Credential', 'MSFT_KeyValuePair', 'MSFT_KeyValuePair[]'
            }
        }

        foreach ($cimProperty in $cimProperties)
        {
            [PSCustomObject]@{
                Name           = $cimProperty.Name
                TypeConstraint = $cimProperty.TypeConstraint
                IsKey          = $cimProperty.IsKey
                Mandatory      = $cimProperty.Mandatory
                Values         = $cimProperty.Values
                Range          = $cimProperty.Range
                ModuleName     = $dscResource.ModuleName
                ResourceName   = $dscResource.Name
            }
            $script:allDscResourcePropertiesTable."$($dscResource.Name)-$($cimProperty.Name)" = $cimProperty
        }

    }
}
