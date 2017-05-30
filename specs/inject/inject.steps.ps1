$PSModuleAutoLoadingPreference = "None"

Given 'we have xCertificate module in the ./module/ folder' {
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    Get-Module -ListAvailable "$RelativePathToDemo/modules/xCertificate" -errorAction SilentlyContinue  | should not BeNullOrEmpty
}

Given 'we have a destination node available' {
    if ( -not ($computername = $Env:TargetNode )) { $computername = 'localhost' }
    if ( -not ($global:creds)) { $global:creds = Get-Credential }
    { Invoke-command -computerName $computername -ScriptBlock { 'checked' } -Credential $global:creds -ErrorAction Stop } | Should not Throw
}

Given 'The module is loaded' {
    $ModulePath = "$PSScriptRoot/../../*/DscBuildHelpers.psd1"
    Test-Path $ModulePath | Should Be $true
    Import-module $ModulePath
    Get-Module DscBuildHelpers | should not BeNullOrEmpty
}

When 'we package-up each module' {
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    if(test-path "$RelativePathToDemo/BuildOutput/xCertificate_*.zip") {
        Remove-Item -force "$RelativePathToDemo/BuildOutput/xCertificate_*.zip*" | out-null
    }
    Find-ModuleToPublish -DscBuildSourceResources (get-item "$RelativePathToDemo/modules/") -DscBuildOutputModules "$RelativePathToDemo/BuildOutput" |
        Compress-DscResourceModule -DscBuildSourceResources (Get-Item "$RelativePathToDemo/modules/") -DscBuildOutputModules "$RelativePathToDemo/BuildOutput"

    if(!(test-path "$RelativePathToDemo/BuildOutput/xCertificate_*.zip")) {
        Throw 'xCertificate Module not packaged up'
    }
}

When 'we transfer those modules to remote node' {
    if ( -not ($computername = $Env:TargetNode )) { $computername = 'localhost' }
    if ( -not ($global:creds)) { $global:creds = Get-Credential }
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    $RemoteNode = New-PSsession -computerName $computername -Credential $global:creds -ErrorAction Stop
    $remoteModules = Invoke-command -Session $RemoteNode -ScriptBlock {Get-Module -ListAvailable}
    $RequiredModules = Get-ModuleFromFolder -ModuleFolder (get-item "$RelativePathToDemo/modules/")
    
    
    #Find all modules that are not available remotely
    # matching exact same Name/version/guid
    $ModulesToInject = $RequiredModules.Where{
        $MatchingModule = foreach ($module in $remoteModules) {
            if(
                $module.Name -eq $_.Name -and
                $module.Version -eq $_.Version -and
                $Module.guid -eq $_.guid
            ) {
                 Write-Verbose "Module match: $($module.Name)"
                $module
            }
        }
        if(!$MatchingModule) {
             Write-Verbose "Module not found: $($_.Name)"
            $_
        }
    }

    #For those modules to inject, find the one that have a non-matching checksum
    # against the local one by checking the remote checksum file, and remote zip file hash
    $ZipFileSpecs = $ModulesToInject.foreach{
        @{
            FileName = "$($_.Name)_$($_.Version).zip"
            Checksum = gc -Raw "$RelativePathToDemo\BuildOutput\$($_.Name)_$($_.Version).zip.checksum"
        }
    }

    $RemotePathToZips = 'C:\TMP\DscPush\'
    $ZipsToInject = Invoke-command -Session $RemoteNode -ScriptBlock {
        Param($PathToZips = 'C:\TMP\DscPush\',$ZipFileSpecs)
        if (!(Test-Path $PathToZips)) {
            mkdir $PathToZips -Force
            return $ZipFileSpecs
        }
        foreach ($ZipToTestChecksum in $ZipFileSpecs) {
            $FilePath = "$PathToZips\$($ZipToTestChecksum.FileName)"
            if (!(Test-Path $FilePath) -or 
                $ZipToTestChecksum.checksum -ne  (Get-Content "$FilePath.checksum" -ErrorAction SilentlyContinue) -or
                $ZipToTestChecksum.checksum -ne (Get-FileHash "$FilePath" -ErrorAction SilentlyContinue).hash
            ) {
                Write-Verbose "$FilePath Checksum ne $($ZipToTestChecksum.Checksum)"
                Write-Output $ZipToTestChecksum
            }
        }
    } -ArgumentList $RemotePathToZips,$ZipFileSpecs

    
    #Then copy the the missing files to the target
    foreach ($Zip in $ZipsToInject) {
        Copy-Item -Path "$RelativePathToDemo\BuildOutput\$($Zip.FileName)*" -ToSession $RemoteNode -Destination $RemotePathToZips -Force
    }

}


<#

When 'we extract to destination module path' {
    throw 'Not Implemented yet'
}

When 'we call get-module -Listavailable' {
    throw 'Not Implemented yet'
}

Then 'the copied modules are present and available' {
    throw 'Not Implemented yet'
}
#>