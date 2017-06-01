$PSModuleAutoLoadingPreference = "None"


When 'we package-up each module' {
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    #cleanup for test
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
    $script:RemoteSession = $RemoteNode
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
    
    $script:ModulesToInject = $ModulesToInject
}

When 'we extract to destination module path' {
    $RemotePathToZips = 'C:\TMP\DscPush'
    if($script:ModulesToInject) {
        Invoke-Command -Session $script:RemoteSession -ScriptBlock {
            Param($ModulesToInject,$PathToZips)
            foreach ($module in $ModulesToInject) {
                $fileName = "$($module.Name)_$($module.version).zip"
                Write-Verbose "Expanding $PathToZips/$fileName to $Env:CommonProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)" 
                Expand-Archive -Path "$PathToZips/$fileName" -DestinationPath "$Env:ProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)" -Force
            }
        } -ArgumentList $script:ModulesToInject,$RemotePathToZips
    }
}

When 'we call Push-DscModuleToNode' {
    #rm C:\TMP\DSC\modules\xCertificate_0.0.0.1.zip* -Force
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    { Push-DscModuleToNode -Module (Get-ModuleFromFolder (gi "$RelativePathToDemo/modules/")) -Session $script:RemoteSession -StagingFolderPath "$RelativePathToDemo/BuildOutput" <# -force #>  } | Should not Throw
}

When 'we call get-module -Listavailable' {
    $script:TestedModules = get-module -ListAvailable xCertificate | ? version -eq '0.0.0.1' 
}

Then 'the copied modules are present and available' {
    $script:TestedModules | should not BeNullOrEmpty
    rm -Force -Recurse -ErrorAction SilentlyContinue "$Env:ProgramW6432\WindowsPowerShell\Modules\xCertificate"
}
