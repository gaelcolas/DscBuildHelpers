<#
.SYNOPSIS
Injects Modules via Session.

.DESCRIPTION
Injects the missing modules on a remote node via a PSSession. 
The module list is checked again the available modules from the remote computer,
Any missing version is then zipped up and sent over the PS session,
before being extracted in the root PSModulePath folder of the remote node.

.PARAMETER Module
A list of Modules required on the remote node. Those missing will be packaged based
on their Path.

.PARAMETER StagingFolderPath
Staging folder where the modules are being zipped up locally before being sent accross.

.PARAMETER Session
Session to use to gather the missing modules and to copy the modules to.

.PARAMETER RemoteStagingPath
Path on the remote Node where the modules will be copied before extraction.

.PARAMETER Force
Force all modules to be re-zipped, re-sent, and re-extracted to the target node.

.EXAMPLE
Push-DscModuleToNode -Module (Get-ModuleFromFolder C:\src\SampleKitchen\modules) -Session $RemoteSession -StagingFolderPath "C:\BuildOutput"

#> 
function Push-DscModuleToNode {
    [CmdletBinding()]
    [OutputType([void])]
    Param (
        # Param1 help description
        [Parameter(
             Mandatory
            ,Position = 0
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        [Alias("ModuleInfo")] 
        [System.Management.Automation.PSModuleInfo[]]
        $Module,
        
        [Parameter(
            ,Position = 1
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        [Alias('DscBuildOutputModules')]
        $StagingFolderPath = "$Env:TMP\DSC\BuildOutput\modules\",


        [Parameter(
            ,Mandatory
            ,Position = 2
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        [Parameter(
            ,Position = 1
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        $RemoteStagingPath = 'C:\TMP\DSC\modules\',

        [switch]
        $Force
    )

    process
    {
        # Find the modules already available remotely
        if (!$Force) {
            $RemoteModuleAvailable = Invoke-command -Session $Session -ScriptBlock {Get-Module -ListAvailable}
        }

        # Find the modules missing on remote node
        $MissingModules = $Module.Where{
            $MatchingModule = foreach ($remoteModule in $RemoteModuleAvailable) {
                if(
                    $remoteModule.Name -eq $_.Name -and
                    $remoteModule.Version -eq $_.Version -and
                    $remoteModule.guid -eq $_.guid
                ) {
                    Write-Verbose "Module match: $($remoteModule.Name)"
                    $remoteModule
                }
            }
            if(!$MatchingModule) {
                Write-Verbose "Module not found: $($_.Name)"
                $_
            }
        }
        Write-Verbose "The Missing modules are $($MissingModules.Name -join ', ')"

        # Find the missing modules from the staging folder
        #  and publish it there
        Write-Verbose "looking for missing zip modules in $($StagingFolderPath)"
        $MissingModules.where{ !(Test-Path "$StagingFolderPath\$($_.Name)_$($_.version).zip")} |
            Compress-DscResourceModule -DscBuildOutputModules $StagingFolderPath
        
        # Copy missing modules to remote node if not present already
        foreach ($module in $MissingModules) {
            $FileName = "$($StagingFolderPath)/$($module.Name)_$($module.Version).zip"
            if ($Force -or !(invoke-command -Session $Session -ScriptBlock {
                    Param($FileName)
                    Test-Path $FileName
                } -ArgumentList $FileName))
            {
                Write-Verbose "Copying $fileName* to $RemoteStagingPath"
                Invoke-Command -Session $Session -ScriptBlock {
                    param($PathToZips)
                    if (!(Test-Path $PathToZips)) {
                        mkdir $PathToZips -Force
                    }
                } -ArgumentList $RemoteStagingPath

                Copy-Item -ToSession $Session `
                    -Path "$($StagingFolderPath)/$($module.Name)_$($module.Version)*" `
                    -Destination $RemoteStagingPath `
                    -Force | Out-Null
            }
            else {
                Write-Verbose "The File is already present remotely."
            }
        }

        # Extract missing modules on remote node to PSModulePath
        Invoke-Command -Session $Session -ScriptBlock {
            Param($MissingModules,$PathToZips)
            foreach ($module in $MissingModules) {
                $fileName = "$($module.Name)_$($module.version).zip"
                Write-Verbose "Expanding $PathToZips/$fileName to $Env:CommonProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)" 
                Expand-Archive -Path "$PathToZips/$fileName" -DestinationPath "$Env:ProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)" -Force
            }
        } -ArgumentList $MissingModules,$RemoteStagingPath
        
    }
}
