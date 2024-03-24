function Get-DscResourceProperty
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSModuleInfo]
        $ModuleInfo,

        [Parameter(Mandatory)]
        [string]
        $ResourceName
    )

    [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ClearCache()
    $functionsToDefine = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,ScriptBlock]'([System.StringComparer]::OrdinalIgnoreCase)
    [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::LoadDefaultCimKeywords($functionsToDefine)

    $schemaFilePath = $null
    $keywordErrors = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Exception]'

    $foundCimSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportCimKeywordsFromModule($ModuleInfo, $ResourceName, [ref] $SchemaFilePath, $functionsToDefine, $keywordErrors)
    if ($foundCimSchema)
    {
        $foundScriptSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportScriptKeywordsFromModule($ModuleInfo, $ResourceName, [ref] $SchemaFilePath, $functionsToDefine)
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

        [PSCustomObject]@{
            Name                = $resourceProperty.Name
            ModuleName          = $ModuleInfo.Name
            ResourceName        = $ResourceName
            TypeConstraint      = $resourceProperty.TypeConstraint
            Attributes          = $resourceProperty.Attributes
            Values              = $resourceProperty.Values
            ValueMap            = $resourceProperty.ValueMap
            Mandatory           = $resourceProperty.Mandatory
            IsKey               = $resourceProperty.IsKey
            Range               = $resourceProperty.Range
            IsDscClassParameter = $dscClassParameterInfo.IsDscClassParameter
            ElementType         = $dscClassParameterInfo.ElementType
            Type                = $dscClassParameterInfo.Type
        }
    }
}
