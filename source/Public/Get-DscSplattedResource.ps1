function Get-DscSplattedResource
{
    <#
    .SYNOPSIS
        Generates a scriptblock for a DSC resource with splatted properties.

    .DESCRIPTION
        The Get-DscSplattedResource function generates a scriptblock for a Desired State Configuration (DSC) resource with splatted properties.
        It constructs the resource block dynamically based on the provided properties and optionally executes it.
        This function is useful for dynamically constructing and invoking DSC resource blocks.

    .PARAMETER ResourceName
        The name of the DSC resource.

    .PARAMETER ExecutionName
        The execution name of the DSC resource.

    .PARAMETER Properties
        A hashtable containing the properties to be splatted into the DSC resource block.

    .PARAMETER NoInvoke
        If specified, the function returns the scriptblock without invoking it.

    .EXAMPLE
        $properties = @{
            Property1 = 'Value1'
            Property2 = 'Value2'
        }
        $scriptblock = Get-DscSplattedResource -ResourceName 'MyResource' -Properties $properties -NoInvoke
        $scriptblock.Invoke($properties)
        This example generates a scriptblock for the 'MyResource' DSC resource with the specified properties and invokes it.

    .NOTES
        This function relies on the Get-CimType and Write-CimProperty functions to retrieve CIM types and write nested properties.
        Ensure that these functions are available in the same scope.

    .LINK
        Get-CimType
        Write-CimProperty
    #>

    [CmdletBinding()]
    [OutputType([scriptblock])]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ResourceName,

        [Parameter()]
        [String]
        $ExecutionName,

        [Parameter()]
        [hashtable]
        $Properties,

        [Parameter()]
        [switch]
        $NoInvoke
    )

    if (-not $script:allDscResourcePropertiesTable -and -not $script:allDscResourcePropertiesTableWarningShown)
    {
        Write-Warning -Message "The 'allDscResourcePropertiesTable' is not defined. This will be an expensive operation. Resources with MOF sub-types are only supported when calling 'Initialize-DscResourceMetaInfo' once before starting the compilation process."
        $script:allDscResourcePropertiesTableWarningShown = $true
    }

    # Remove Case Sensitivity of ordered Dictionary or Hashtables
    $Properties = @{} + $Properties

    $stringBuilder = [System.Text.StringBuilder]::new()
    $null = $stringBuilder.AppendLine("Param([hashtable]`$Parameters)")
    $null = $stringBuilder.AppendLine()

    if ($ExecutionName)
    {
        $null = $stringBuilder.AppendLine("$ResourceName '$ExecutionName' {")
    }
    else
    {
        $null = $stringBuilder.AppendLine("$ResourceName {")
    }

    foreach ($propertyName in $Properties.Keys)
    {
        $cimProperty = Get-CimType -DscResourceName $ResourceName -PropertyName $propertyName
        if ($cimProperty)
        {
            Write-CimProperty -StringBuilder $stringBuilder -CimProperty $cimProperty -Path $propertyName -ResourceName $ResourceName
        }
        else
        {
            $null = $stringBuilder.AppendLine("$propertyName = `$Parameters['$propertyName']")
        }
    }

    $null = $stringBuilder.AppendLine('}')
    Write-Debug -Message ('Generated Resource Block = {0}' -f $stringBuilder.ToString())

    if ($NoInvoke)
    {
        [scriptblock]::Create($stringBuilder.ToString())
    }
    else
    {
        if ($Properties)
        {
            [scriptblock]::Create($stringBuilder.ToString()).Invoke($Properties)
        }
        else
        {
            [scriptblock]::Create($stringBuilder.ToString()).Invoke()
        }
    }
}

Set-Alias -Name x -Value Get-DscSplattedResource -Scope Global
