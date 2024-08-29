function Get-DscCimInstanceReference
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='For debugging purposes')]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [string]
        $ParameterName,

        [Parameter()]
        [object]
        $Data
    )

    if ($Script:allDscResourcePropertiesTable)
    {
        if ($allDscResourcePropertiesTable.ContainsKey("$($ResourceName)-$($ParameterName)"))
        {
            $p = $allDscResourcePropertiesTable."$($ResourceName)-$($ParameterName)"
            $typeConstraint = $p.TypeConstraint -replace '\[\]', ''
            Get-DscSplattedResource -ResourceName $typeConstraint -Properties $Data -NoInvoke
        }
    }
    else
    {
        Write-Host "No DSC Resource Properties metadata was found, cannot translate CimInstance parameters. Call 'Initialize-DscResourceMetaInfo' first is this is needed."
    }
}
