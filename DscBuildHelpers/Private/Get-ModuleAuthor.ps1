
function Get-ModuleAuthor
{
    param (
        [parameter(mandatory)]
        [validatenotnullorempty()]
        [string]
        $path
    )
    $ModuleName = split-path $path -Leaf
    $ModulePSD1 = join-path $path "$ModuleName.psd1"

    if (Test-Path $ModulePSD1)
    {
        $hashtable = Import-DataFile -Path $ModulePSD1
        $Author = $hashtable['Author']
        Write-Verbose "Found author $Author for $ModuleName."
        return $Author
    }
    else
    {
        Write-Warning "Could not find a PSD1 for $modulename at $ModulePSD1."
    }
}

New-Alias -Name Get-DscResourceVersion -Value Get-ModuleVersion -Force
