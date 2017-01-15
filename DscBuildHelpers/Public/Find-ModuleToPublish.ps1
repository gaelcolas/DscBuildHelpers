function Find-ModuleToPublish {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $DscBuildSourceResources,
        
        [string[]]
        $ExcludedFolder = @('.g*','.hg'),

        [ValidateNotNullOrEmpty()]
        [string[]]
        $ExcludedModules = $script:DscBuildParameters.ExcludedModules,

        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputModules
    )

    #if ( Test-BuildResource ) {
    $resourceFolders = Get-ChildItem $DscBuildSourceResources -Exclude $ExcludedFolder -Directory
    Write-Verbose "found those folders: $($resourceFolders.BaseName -join ', ')"
    $ModulesToPublish = @(
        $resourceFolders.Where{$ExcludedModules -notcontains $_.Name } |
          ForEach-Object {
            $source = $_
            Write-Debug "Evaluating folder $($source.FullName)"
            $sourceVersion = Get-DscResourceVersion -Path $source.FullName -AsVersion
            Write-Debug "$($source.BaseName) is of Version $sourceVersion"

            $publishTargetZip =  [System.IO.Path]::Combine(
                                                $DscBuildOutputModules,
                                                "$($source.Name)_$sourceVersion.zip"
                                                )
                                                
            $publishTargetZipCheckSum =  [System.IO.Path]::Combine(
                                                $DscBuildOutputModules,
                                                "$($source.Name)_$sourceVersion.zip.checksum"
                                                )
            $zipExists      = Test-Path -Path $publishTargetZip
            $checksumExists = Test-Path -Path $publishTargetZipCheckSum

            if (-not ($zipExists -and $checksumExists))
            {
                Write-Debug "ZipExists = $zipExists; CheckSum exists = $checksumExists"
                Write-Verbose -Message "Adding $($source.Name) to the Modules To Publish"
                $source.Name
            }
            else {
                Write-Verbose -Message "$($source.Name) does not need to be published"
            }
         }
    )
    Write-Output -InputObject $ModulesToPublish
   #}
   #else {
   #    Write-Verbose "Test-BuidResource returned false"
   #}
}