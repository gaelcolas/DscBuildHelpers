function Get-DynamicTypeObject
{
    <#
    .SYNOPSIS
        Retrieves the dynamic type of a given object.

    .DESCRIPTION
        The Get-DynamicTypeObject function returns the dynamic type of a given object.
        It checks for various properties (ElementType, PropertyType, Type) to determine the type of the object.

    .PARAMETER Object
        The object for which to retrieve the dynamic type.

    .EXAMPLE
        $type = Get-DynamicTypeObject -Object $myObject
        This example retrieves the dynamic type of the object stored in the $myObject variable.

    .OUTPUTS
        System.Type
            The dynamic type of the specified object.

    .NOTES
        This function is useful for dynamically determining the type of an object, especially in scenarios where the type may not be known at design time.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]
        $Object
    )

    if ($Object.ElementType)
    {
        return $Object.Type.GetElementType()
    }
    elseif ($Object.PropertyType)
    {
        return $Object.PropertyType
    }
    elseif ($Object.Type)
    {
        return $Object.Type
    }
    else
    {
        return $Object
    }
}
