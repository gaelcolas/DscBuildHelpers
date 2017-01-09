
function Import-DataFile
{
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    try
    {
        $content = Get-Content -Path $path -Raw -ErrorAction Stop
        $scriptBlock = [scriptblock]::Create($content)

        [string[]] $allowedCommands = @(
            'Import-LocalizedData', 'ConvertFrom-StringData', 'Write-Host', 'Out-Host', 'Join-Path'
        )

        [string[]] $allowedVariables = @('PSScriptRoot')

        $scriptBlock.CheckRestrictedLanguage($allowedCommands, $allowedVariables, $true)

        return & $scriptBlock
    }
    catch
    {
        throw
    }
}
