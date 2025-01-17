function Initialize-DscResourceMetaInfo
{
    <#
    .SYNOPSIS
        Initializes the metadata information for DSC resources.

    .DESCRIPTION
        The Initialize-DscResourceMetaInfo function initializes the metadata information for Desired State Configuration (DSC) resources.
        It retrieves the properties and schema classes for DSC resources from the specified module path and stores them in a global variable.
        This function is useful for preparing DSC resource metadata for further processing or validation.

    .PARAMETER ModulePath
        The path to the module containing the DSC resources.

    .PARAMETER ReturnAllProperties
        If specified, all properties of the DSC resources will be returned, including standard CIM types.

    .PARAMETER Force
        If specified, the metadata information will be re-initialized even if it has already been initialized.

    .PARAMETER PassThru
        If specified, the function will return the metadata information as an output.

    .EXAMPLE
        Initialize-DscResourceMetaInfo -ModulePath 'C:\Modules\DscResources'
        This example initializes the metadata information for DSC resources located in the 'C:\Modules\DscResources' path.

    .EXAMPLE
        $metadata = Initialize-DscResourceMetaInfo -ModulePath 'C:\Modules\DscResources' -PassThru
        This example initializes the metadata information for DSC resources and returns it as an output.

    .NOTES
        This function relies on the Get-ModuleFromFolder, Get-DscResourceFromModuleInFolder, and Get-DscResourceProperty functions to retrieve module and resource information.
        Ensure that these functions are available in the same scope.

    .LINK
        Get-ModuleFromFolder
        Get-DscResourceFromModuleInFolder
        Get-DscResourceProperty
    #>

    param (
        [Parameter(Mandatory = $true)]
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

    if (-not (Test-Path -Path $ModulePath))
    {
        Write-Error -Message "The module path '$ModulePath' does not exist."
        return
    }

    $allModules = Get-ModuleFromFolder -ModuleFolder $ModulePath
    if ($null -eq $allModules -or $allModules.Count -eq 0)
    {
        Write-Error -Message "No modules found in the module path '$ModulePath'."
        return
    }

    $allModules = Get-ModuleFromFolder -ModuleFolder $ModulePath
    $allDscResources = Get-DscResourceFromModuleInFolder -ModuleFolder $ModulePath -Modules $allModules
    $modulesWithDscResources = $allDscResources | Select-Object -ExpandProperty ModuleName -Unique
    $modulesWithDscResources = $allModules | Where-Object Name -In $modulesWithDscResources

    $script:standardCimTypes = Get-StandardCimType

    $script:allDscResourcePropertiesTable = @{}
    $script:allDscSchemaClasses = @()

    $script:allDscResourceProperties = foreach ($dscResource in $allDscResources)
    {
        $moduleInfo = $modulesWithDscResources |
            Where-Object { $_.Name -EQ $dscResource.ModuleName -and $_.Version -eq $dscResource.Version }

        $dscModule = [System.Tuple]::Create($dscResource.Module.Name, [System.Version]$dscResource.Version)
        $exceptionCollection = [System.Collections.ObjectModel.Collection[System.Exception]]::new()
        $schemaMofFile = [System.IO.Path]::ChangeExtension($dscResource.Path, 'schema.mof')

        if (Test-Path -Path $schemaMofFile)
        {
            $dscSchemaClasses = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportClasses($schemaMofFile, $dscModule, $exceptionCollection)
            foreach ($dscSchemaClass in $dscSchemaClasses)
            {
                $dscSchemaClass | Add-Member -Name ModuleName -MemberType NoteProperty -Value $dscResource.ModuleName
                $dscSchemaClass | Add-Member -Name ModuleVersion -MemberType NoteProperty -Value $dscResource.Version
                $dscSchemaClass | Add-Member -Name ResourceName -MemberType NoteProperty -Value $dscResource.Name
            }
            $script:allDscSchemaClasses += $dscSchemaClasses
        }

        $cimProperties = if ($ReturnAllProperties)
        {
            Get-DscResourceProperty -ModuleInfo $moduleInfo -ResourceName $dscResource.Name
        }
        else
        {
            Get-DscResourceProperty -ModuleInfo $moduleInfo -ResourceName $dscResource.Name |
                Where-Object TypeConstraint -NotIn $script:standardCimTypes.CimType
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
