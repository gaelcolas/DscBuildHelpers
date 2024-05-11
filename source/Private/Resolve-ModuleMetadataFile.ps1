
function Resolve-ModuleMetadataFile
{
    [CmdletBinding(DefaultParameterSetName = 'ByDirectoryInfo')]
    param (
        [Parameter(ParameterSetName = 'ByPath', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ByDirectoryInfo', Mandatory = $true, ValueFromPipeline = $true)]
        [System.IO.DirectoryInfo]
        $InputObject
    )

    process
    {
        $metadataFileFound = $true
        $metadataFilePath = ''
        Write-Verbose "Using Parameter set - $($PSCmdlet.ParameterSetName)."
        switch ($PSCmdlet.ParameterSetName)
        {
            'ByPath'
            {
                Write-Verbose "Testing Path - $path."
                if (Test-Path -Path $Path)
                {
                    Write-Verbose "`tFound $path."
                    $item = (Get-Item -Path $Path)
                    if ($item.PSIsContainer)
                    {
                        Write-Verbose "`t`tIt is a folder."
                        $moduleName = Split-Path $Path -Leaf
                        $metadataFilePath = Join-Path -Path $Path -ChildPath "$moduleName.psd1"
                        $metadataFileFound = Test-Path -Path $metadataFilePath
                    }
                    else
                    {
                        if ($item.Extension -like '.psd1')
                        {
                            Write-Verbose "`t`tIt is a module metadata file."
                            $metadataFilePath = $item.FullName
                            $metadataFileFound = $true
                        }
                        else
                        {
                            $modulePath = Split-Path -Path $Path
                            Write-Verbose "`t`tSearching for module metadata folder in '$ModulePath'."
                            $moduleName = Split-Path $modulePath -Leaf
                            Write-Verbose "`t`tModule name is '$moduleName'."
                            $metadataFilePath = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
                            Write-Verbose "`t`tChecking for '$metadataFilePath'."
                            $metadataFileFound = Test-Path -Path $metadataFilePath
                        }
                    }
                }
                else
                {
                    $metadataFileFound = $false
                }
            }
            'ByDirectoryInfo'
            {
                $moduleName = $InputObject.Name
                $metadataFilePath = Join-Path -Path $InputObject.FullName -ChildPath "$moduleName.psd1"
                $metadataFileFound = Test-Path -Path $metadataFilePath
            }
        }

        if ($metadataFileFound -and (-not [string]::IsNullOrEmpty($metadataFilePath)))
        {
            Write-Verbose "Found a module metadata file at '$metadataFilePath'."
            Convert-Path -Path $metadataFilePath
        }
        else
        {
            Write-Error "Failed to find a module metadata file at '$metadataFilePath'."
        }
    }
}
