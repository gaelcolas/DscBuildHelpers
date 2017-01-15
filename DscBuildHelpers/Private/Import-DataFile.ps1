function Import-DataFile
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] 
        $Path
    )
    
    Write-Verbose -Message ('Opening file {0}' -f $Path)
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