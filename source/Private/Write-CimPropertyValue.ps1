function Write-CimPropertyValue
{
    <#
    .SYNOPSIS
        Writes the value of a CIM property to a StringBuilder object.

    .DESCRIPTION
        The Write-CimPropertyValue function appends the value of a CIM (Common Information Model) property to a StringBuilder object.
        It handles both single properties and arrays, and recursively writes nested properties if necessary.
        This function is useful for dynamically constructing DSC (Desired State Configuration) resource blocks.

    .PARAMETER StringBuilder
        The StringBuilder object to which the CIM property value will be appended.

    .PARAMETER CimProperty
        The CIM property object containing the property value.

    .PARAMETER Path
        An array of strings representing the property path.

    .PARAMETER ResourceName
        The name of the DSC resource.

    .EXAMPLE
        $stringBuilder = [System.Text.StringBuilder]::new()
        Write-CimPropertyValue -StringBuilder $stringBuilder -CimProperty $cimProperty -Path 'Property1' -ResourceName 'MyResource'

        This example appends the value of the 'Property1' CIM property of the 'MyResource' DSC resource to the StringBuilder object.

    .NOTES
        This function relies on the Get-PropertiesData and Get-DynamicTypeObject functions to retrieve property values and determine the type of the CIM property.
        Ensure that these functions are available in the same scope.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Text.StringBuilder]
        $StringBuilder,

        [Parameter(Mandatory = $true)]
        [object]
        $CimProperty,

        [Parameter(Mandatory = $true)]
        [string[]]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName
    )

    $type = Get-DynamicTypeObject -Object $CimProperty
    if ($type.IsArray)
    {
        if ($type -is [pscustomobject])
        {
            $typeName = $type.TypeConstraint -replace '\[\]', ''
            $typeProperties = ($allDscSchemaClasses.Where({ $_.CimClassName -eq $typeName -and $_.ResourceName -eq $ResourceName })).CimClassProperties
        }
        else
        {
            $typeName = $type.Name -replace '\[\]', ''
            $typeProperties = $type.GetElementType().GetProperties().Where({ $_.CustomAttributes.AttributeType.Name -eq 'DscPropertyAttribute' })
        }
    }
    else
    {
        if ($type -is [pscustomobject])
        {
            $typeName = $type.TypeConstraint
            $typeProperties = ($allDscSchemaClasses.Where({ $_.CimClassName -eq $typeName -and $_.ResourceName -eq $ResourceName })).CimClassProperties
        }
        elseif ($type -is [type])
        {
            $typeName = $type.Name
            $typeProperties = $type.GetProperties().Where({ $_.CustomAttributes.AttributeType.Name -eq 'DscPropertyAttribute' })
        }
        elseif ($type.GetType().FullName -eq 'Microsoft.Management.Infrastructure.Internal.Data.CimClassPropertyOfClass')
        {
            $typeName = $type.ReferenceClassName
            $typeProperties = ($allDscSchemaClasses.Where({ $_.CimClassName -eq $typeName -and $_.ResourceName -eq $ResourceName })).CimClassProperties
        }
    }

    $null = $StringBuilder.AppendLine($typeName)
    $null = $StringBuilder.AppendLine('{')

    foreach ($property in $typeProperties)
    {
        $isCimProperty = if ($property.GetType().Name -eq 'CimClassPropertyOfClass')
        {
            if ($property.CimType -in 'Instance', 'InstanceArray')
            {
                $true
            }
            else
            {
                $property.CimType -notin $script:standardCimTypes.CimType
            }
        }
        else
        {
            $property.PropertyType.FullName -notin $script:standardCimTypes.DotNetType -and $property.PropertyType.BaseType -ne [System.Enum]
        }

        $pathValue = Get-PropertiesData -Path ($Path + $property.Name)

        if ($null -ne $pathValue)
        {
            if ($isCimProperty)
            {
                Write-CimProperty -StringBuilder $StringBuilder -CimProperty $property -Path ($Path + $property.Name) -ResourceName $ResourceName
            }
            else
            {
                $paths = foreach ($p in $Path)
                {
                    "['$p']"
                }
                $null = $StringBuilder.AppendLine("$($property.Name) = `$Parameters$($paths -join '')['$($property.Name)']")
            }
        }
    }

    $null = $StringBuilder.AppendLine('}')
}
