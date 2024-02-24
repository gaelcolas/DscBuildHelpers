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
        $Force,

        [Parameter()]
        [switch]
        $PassThru
    )

    if ($script:allDscResourcePropertiesTable.Count -ne 0 -and -not $Force)
    {
        if ($PassThru)
        {
            return $script:allDscResourcePropertiesTable
        }
        else
        {
            return
        }
    }

    $allModules = Get-ModuleFromFolder -ModuleFolder $ModulePath
    $allDscResources = Get-DscResourceFromModuleInFolder -ModuleFolder $ModulePath -Modules $allModules
    $modulesWithDscResources = $allDscResources | Select-Object -ExpandProperty ModuleName -Unique
    $modulesWithDscResources = $allModules | Where-Object Name -In $modulesWithDscResources

    $script:allDscResourcePropertiesTable = @{}

    $script:allDscResourceProperties = foreach ($dscResource in $allDscResources)
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
                        $_.TypeConstraint -match '(DSC|MSFT)_.+' -and
                        $_.TypeConstraint -notin 'MSFT_Credential', 'MSFT_KeyValuePair', 'MSFT_KeyValuePair[]'
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

    if ($PassThru)
    {
        $script:allDscResourcePropertiesTable
    }
}
