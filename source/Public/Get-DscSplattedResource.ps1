function Get-DscSplattedResource
{
    [CmdletBinding()]
    Param(
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

    if (-not $script:allDscResourcePropertiesTable -and -not $script:allDscResourcePropertiesTableWarningShown) {
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

    foreach ($PropertyName in $Properties.Keys) {

        $cimType = $allDscResourcePropertiesTable."$ResourceName-$PropertyName"
        if ($cimType)
        {
            $isCimArray = $cimType.TypeConstraint.EndsWith("[]")
            $cimProperties = $Properties.$PropertyName
            $null = $stringBuilder.AppendLine("$PropertyName = {0}" -f $(if ($isCimArray) { '@(' } else { "$($cimType.TypeConstraint.Replace('[]', '')) {" }))
            if ($isCimArray)
            {
                if ($Properties.$PropertyName -isnot [array])
                {
                    Write-Warning -Message "The property '$PropertyName' is an array and the BindingInfo data is not an array" -ErrorAction Stop
                }

                $i = 0
                foreach ($cimPropertyValue in $cimProperties)
                {
                    $null = $stringBuilder.AppendLine($cimType.TypeConstraint.Replace('[]', ''))
                    $null = $stringBuilder.AppendLine("{")

                    foreach ($cimSubProperty in $cimPropertyValue.GetEnumerator())
                    {
                        $null = $stringBuilder.AppendLine("$($cimSubProperty.Name) = `$(`$Parameters['$PropertyName'][$($i)]['$($cimSubProperty.Name)'])")

                    }

                    $null = $stringBuilder.AppendLine("}")
                    $i++
                }

                $null = $stringBuilder.AppendLine('{0}' -f $(if ($isCimArray) { ')' }))
            }
            else
            {
                foreach ($cimProperty in $cimProperties.GetEnumerator())
                {
                    $null = $stringBuilder.AppendLine("$($cimProperty.Name) = `$(`$Parameters['$PropertyName']['$($cimProperty.Name)'])")
                }

                $null = $stringBuilder.AppendLine("}")
            }
        }
        else
        {
            $null = $stringBuilder.AppendLine("$PropertyName = `$Parameters['$PropertyName']")
        }
    }

    $null = $stringBuilder.AppendLine("}")
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
        } else
        {
            [scriptblock]::Create($stringBuilder.ToString()).Invoke()
        }
    }
}

Set-Alias -Name x -Value Get-DscSplattedResource -Scope Global
