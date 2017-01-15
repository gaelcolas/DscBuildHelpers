function Get-DscResourceVersion
{
    param (
        [parameter(mandatory)]
        [validatenotnullorempty()]
        [string]
        $path,
        [switch]
        $asVersion
    )
    $ModuleName = split-path $path -Leaf
    $ModulePSD1 = join-path $path "$ModuleName.psd1"
    if ( #If the module is directly under this folder
        ($ModulePSD1 = join-path $path "$ModuleName.psd1") -and
         (Test-Path $ModulePSD1)
       ) {
        Write-Debug "Using $ModulePSD1 to determine version"

        $hashtable = Import-DataFile -Path $ModulePSD1
        $Version = $hashtable['ModuleVersion']
        Write-Verbose "Found version $Version for $ModuleName."
    }
    elseif ( #If the module is in a version subfolder (as when using save-module)
            ($ModuleSubFolder = Get-ChildItem $path | Sort-Object -Descending) -and
            ($version = $ModuleSubFolder[0].BaseName -as [Version])
           ) {
        if ($ModuleSubFolder.count -gt 1) {
            Write-Warning -Message "More than 1 folder found in $Path. Using highest version."
        }
        Write-Verbose -Message "Version folder = $version"
    }
    else 
    {
        Write-Warning "Could not find version for $modulename at $path."
    }

    if ($asVersion) {
        [Version]::parse($Version)
    }
    else {
        return $Version
    }
}

