function Get-CimType
{
    <#
    .SYNOPSIS
        Retrieves the CIM type for a specified DSC resource property.

    .DESCRIPTION
        The Get-CimType function retrieves the CIM (Common Information Model) type for a specified property of a DSC (Desired State Configuration) resource.
        If the property is not a CIM type, it returns null and writes a verbose message.

    .PARAMETER DscResourceName
        The name of the DSC resource.

    .PARAMETER PropertyName
        The name of the property for which to retrieve the CIM type.

    .EXAMPLE
        $cimType = Get-CimType -DscResourceName 'MyDscResource' -PropertyName 'MyProperty'
        This example retrieves the CIM type for the 'MyProperty' property of the 'MyDscResource' DSC resource.

    .OUTPUTS
        System.Object
            The CIM type of the specified property, or null if the property is not a CIM type.

    .NOTES
        This function relies on a global variable named $allDscResourcePropertiesTable to retrieve the CIM type.
        Ensure that this variable is properly initialized and populated before calling this function.
    #>

    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DscResourceName,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyName
    )

    $cimType = $allDscResourcePropertiesTable."$ResourceName-$PropertyName"

    if ($null -eq $cimType)
    {
        Write-Verbose "The CIM Type for DSC resource '$DscResourceName' with the name '$PropertyName'. It is not a CIM type."
        return
    }

    return $cimType
}
