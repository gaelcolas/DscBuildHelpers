function Get-DscResourceProperty
{
    <#
    .SYNOPSIS
        Retrieves the properties of a specified DSC resource.

    .DESCRIPTION
        The Get-DscResourceProperty function retrieves the properties of a specified DSC (Desired State Configuration) resource.
        It imports the module containing the DSC resource and loads the CIM (Common Information Model) keywords and class resources.
        The function returns a collection of properties for the specified DSC resource.

    .PARAMETER ModuleInfo
        The PSModuleInfo object representing the module containing the DSC resource.
        This parameter is mandatory if ModuleName is not specified.

    .PARAMETER ModuleName
        The name of the module containing the DSC resource.
        This parameter is mandatory if ModuleInfo is not specified.

    .PARAMETER ResourceName
        The name of the DSC resource for which to retrieve the properties.

    .EXAMPLE
        $properties = Get-DscResourceProperty -ModuleName 'MyDscModule' -ResourceName 'MyDscResource'

        This example retrieves the properties of the 'MyDscResource' DSC resource from the 'MyDscModule' module.

    .EXAMPLE
        $module = Get-Module -Name 'MyDscModule' -ListAvailable
        $properties = Get-DscResourceProperty -ModuleInfo $module -ResourceName 'MyDscResource'

        This example retrieves the properties of the 'MyDscResource' DSC resource from the 'MyDscModule' module using the PSModuleInfo object.

    .OUTPUTS
        System.Collections.Generic.Dictionary[string, object]
            A collection of properties for the specified DSC resource.

    .NOTES
        This function relies on the Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache class to load CIM keywords and class resources.
        Ensure that the module containing the DSC resource is available and can be imported.
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ModuleInfo')]
        [System.Management.Automation.PSModuleInfo]
        $ModuleInfo,

        [Parameter(Mandatory = $true, ParameterSetName = 'ModuleName')]
        [string]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName
    )

    if ($ModuleName)
    {
        if (Get-Module -Name $ModuleName)
        {
            $ModuleInfo = Get-Module -Name $ModuleName
        }
        else
        {
            $ModuleInfo = Import-Module -Name $ModuleName -PassThru -Force
        }
    }
    else
    {
        if (Get-Module -Name $ModuleInfo.Name)
        {
            $ModuleInfo = Get-Module -Name $ModuleInfo.Name
        }
        else
        {
            $ModuleInfo = Import-Module -Name $ModuleInfo.Name -PassThru -Force
        }
    }

    [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ClearCache()
    $functionsToDefine = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,ScriptBlock]'([System.StringComparer]::OrdinalIgnoreCase)
    [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::LoadDefaultCimKeywords($functionsToDefine)

    $schemaFilePath = $null
    $keywordErrors = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Exception]'

    $foundCimSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportCimKeywordsFromModule($ModuleInfo, $ResourceName, [ref] $SchemaFilePath, $functionsToDefine, $keywordErrors)
    if ($foundCimSchema)
    {
        [void][Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportScriptKeywordsFromModule($ModuleInfo, $ResourceName, [ref] $SchemaFilePath, $functionsToDefine)
    }
    else
    {
        [System.Collections.Generic.List[string]]$resourceNameAsList = $ResourceName
        [void][Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportClassResourcesFromModule($ModuleInfo, $resourceNameAsList, $functionsToDefine)
    }

    $resourceProperties = ([System.Management.Automation.Language.DynamicKeyword]::GetKeyword($ResourceName)).Properties

    foreach ($key in $resourceProperties.Keys)
    {
        $resourceProperty = $resourceProperties.$key

        $dscClassParameterInfo = & $ModuleInfo {

            param (
                [Parameter(Mandatory = $true)]
                [string]$TypeName
            )

            $result = @{
                ElementType = $null
                Type        = $null
                IsArray     = $false
            }

            $result.Type = $TypeName -as [type]

            if ($null -eq $result.Type)
            {
                Write-Verbose "The type '$TypeName' could not be resolved."
            }

            if ($result.Type -and $result.Type.IsArray)
            {
                $result.ElementType = $result.Type.GetElementType().FullName
                $result.IsArray = $true
            }

            return $result

        } $resourceProperty.TypeConstraint

        $isArrayType = if ($null -ne $dscClassParameterInfo.Type)
        {
            $dscClassParameterInfo.IsArray
        }
        else
        {
            $resourceProperty.TypeConstraint -match '.+\[\]'
        }

        [PSCustomObject]@{
            Name           = $resourceProperty.Name
            ModuleName     = $ModuleInfo.Name
            ResourceName   = $ResourceName
            TypeConstraint = $resourceProperty.TypeConstraint
            Attributes     = $resourceProperty.Attributes
            Values         = $resourceProperty.Values
            ValueMap       = $resourceProperty.ValueMap
            Mandatory      = $resourceProperty.Mandatory
            IsKey          = $resourceProperty.IsKey
            Range          = $resourceProperty.Range
            IsArray        = $isArrayType
            ElementType    = $dscClassParameterInfo.ElementType
            Type           = $dscClassParameterInfo.Type
        }
    }
}
