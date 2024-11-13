function Get-PropertiesData
{
    <#
    .SYNOPSIS
        Retrieves the value of a specified property path from a global properties variable.

    .DESCRIPTION
        The Get-PropertiesData function retrieves the value of a specified property path from a global properties variable.
        It constructs the path dynamically and uses Invoke-Expression to evaluate the path and return the value.
        This function is useful for accessing nested properties in a dynamic and flexible manner.

    .PARAMETER Path
        An array of strings representing the property path to retrieve the value from.

    .EXAMPLE
        $value = Get-PropertiesData -Path 'Property1', 'SubProperty'

        This example retrieves the value of 'SubProperty' under 'Property1' from the global properties variable.

    .EXAMPLE
        $value = Get-PropertiesData -Path 'Settings', 'Database', 'ConnectionString'

        This example retrieves the value of 'ConnectionString' under 'Settings -> Database' from the global properties variable.

    .OUTPUTS
        System.Object
            The value of the specified property path, or null if the path does not exist.

    .NOTES
        This function relies on a global variable named $Properties to retrieve the data.
        Ensure that the $Properties variable is properly initialized and populated before calling this function.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Path
    )

    $paths = foreach ($p in $Path)
    {
        "['$p']"
    }

    $pathValue = try
    {
        Invoke-Expression "`$Properties$($paths -join '')"
    }
    catch
    {
        $null
    }

    return $pathValue
}
