function Write-CimProperty
{
    <#
    .SYNOPSIS
        Writes the CIM property definition to a StringBuilder object.

    .DESCRIPTION
        The Write-CimProperty function appends the definition of a CIM (Common Information Model) property to a StringBuilder object.
        It handles both single properties and arrays, and recursively writes nested properties if necessary.
        This function is useful for dynamically constructing DSC (Desired State Configuration) resource blocks.

    .PARAMETER StringBuilder
        The StringBuilder object to which the CIM property definition will be appended.

    .PARAMETER CimProperty
        The CIM property object containing the property definition.

    .PARAMETER Path
        An array of strings representing the property path.

    .PARAMETER ResourceName
        The name of the DSC resource.

    .EXAMPLE
        $stringBuilder = [System.Text.StringBuilder]::new()
        Write-CimProperty -StringBuilder $stringBuilder -CimProperty $cimProperty -Path 'Property1' -ResourceName 'MyResource'

        This example appends the definition of the 'Property1' CIM property of the 'MyResource' DSC resource to the StringBuilder object.

    .OUTPUTS
        None. The function modifies the StringBuilder object in place.

    .NOTES
        This function relies on the Get-PropertiesData and Write-CimPropertyValue functions to retrieve property values and write nested properties.
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

    $null = $StringBuilder.Append("$($CimProperty.Name) = ")
    if ($CimProperty.IsArray -or $CimProperty.PropertyType.IsArray -or $CimProperty.CimType -eq 'InstanceArray')
    {
        $null = $StringBuilder.Append("@(`n")

        $pathValue = Get-PropertiesData -Path $Path

        $i = 0
        foreach ($element in $pathValue)
        {
            $p = $Path + $i
            Write-CimPropertyValue -StringBuilder $StringBuilder -CimProperty $CimProperty -Path $p -ResourceName $ResourceName
            $i++
        }

        $null = $StringBuilder.Append(")`n")
    }
    else
    {
        Write-CimPropertyValue -StringBuilder $StringBuilder -CimProperty $CimProperty -Path $Path -ResourceName $ResourceName
    }
}
