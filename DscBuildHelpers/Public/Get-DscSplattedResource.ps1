function Get-DscSplattedResource
{
    [CmdletBinding()]
    Param(
        [String]
        $ResourceName,

        [String]
        $ExecutionName,

        [hashtable]
        $Properties,

        [switch]
        $NoInvoke
    )
    # Remove Case Sensitivity of ordered Dictionary or Hashtables
    $Properties = @{} + $Properties

    $stringBuilder = [System.Text.StringBuilder]::new()
    $null = $stringBuilder.AppendLine("Param([hashtable]`$Parameters)")
    $null = $stringBuilder.AppendLine()

    if ($ExecutionName) {
        $null = $stringBuilder.AppendLine(" $ResourceName '$ExecutionName' {")
    }
    else {
        $null = $stringBuilder.AppendLine(" $ResourceName {")
    }

    foreach ($PropertyName in $Properties.Keys) {
        $null = $stringBuilder.AppendLine("$PropertyName = `$(`$Parameters['$PropertyName'])")
    }
    $null = $stringBuilder.AppendLine('}')
    Write-Debug ('Generated Resource Block = {0}' -f $stringBuilder.ToString())

    if ($NoInvoke) {
        [scriptblock]::Create($stringBuilder.ToString())
    }
    else {
        if ($Properties) {
            [scriptblock]::Create($stringBuilder.ToString()).Invoke($Properties)
        } else {
            [scriptblock]::Create($stringBuilder.ToString()).Invoke()
        }
    }
}

Set-Alias -Name x -Value Get-DscSplattedResource -Scope Global
