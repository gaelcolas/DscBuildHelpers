<#
    .SYNOPSIS
    Injects Modules via PS Session.

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
function Push-DscModuleToNode
{
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # Param1 help description
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        [Alias('ModuleInfo')]
        [System.Management.Automation.PSModuleInfo[]]
        $Module,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        [Alias('DscBuildOutputModules')]
        $StagingFolderPath = "$Env:TMP\DSC\BuildOutput\modules\",

        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        $RemoteStagingPath = '$Env:TMP\DSC\modules\',

        [Parameter(Position = 4, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        [switch]
        $Force
    )

    process
    {
        # Find the modules already available remotely
        if (-not $Force)
        {
            $remoteModuleAvailable = Invoke-Command -Session $Session -ScriptBlock {
                Get-Module -ListAvailable
            }
        }

        $resolvedRemoteStagingPath = Invoke-Command -Session $Session -ScriptBlock {
            $ResolvedStagingPath = $ExecutionContext.InvokeCommand.ExpandString($using:RemoteStagingPath)
            if (-not (Test-Path $ResolvedStagingPath))
            {
                mkdir -Force $ResolvedStagingPath
            }
            $resolvedStagingPath
        }

        # Find the modules missing on remote node
        $missingModules = $Module.Where{
            $matchingModule = foreach ($remoteModule in $RemoteModuleAvailable)
            {
                if (
                    $remoteModule.Name -eq $_.Name -and
                    $remoteModule.Version -eq $_.Version -and
                    $remoteModule.Guid -eq $_.Guid
                )
                {
                    Write-Verbose "Module match: '$($remoteModule.Name)'."
                    $remoteModule
                }
            }
            if (-not $matchingModule)
            {
                Write-Verbose "Module not found: '$($_.Name)'."
                $_
            }
        }
        Write-Verbose "The Missing modules are '$($MissingModules.Name -join ', ')'."

        # Find the missing modules from the staging folder
        #  and publish it there
        Write-Verbose "Looking for missing zip modules in '$($StagingFolderPath)'."
        $missingModules.Where{ -not (Test-Path -Path "$StagingFolderPath\$($_.Name)_$($_.version).zip") } |
            Compress-DscResourceModule -DscBuildOutputModules $StagingFolderPath

        # Copy missing modules to remote node if not present already
        foreach ($module in $missingModules)
        {
            $fileName = "$($StagingFolderPath)/$($module.Name)_$($module.Version).zip"
            $testPathResult = Invoke-Command -Session $Session -ScriptBlock {
                param (
                    [Parameter(Mandatory = $true)]
                    [string]
                    $FileName
                )
                Test-Path -Path $FileName
            } -ArgumentList $fileName

            if ($Force -or -not ($testPathResult))
            {
                Write-Verbose "Copying '$fileName*' to '$ResolvedRemoteStagingPath'."
                Invoke-Command -Session $Session -ScriptBlock {
                    param (
                        [Parameter(Mandatory = $true)]
                        [string]
                        $PathToZips
                    )
                    if (-not (Test-Path -Path $PathToZips))
                    {
                        mkdir -Path $PathToZips -Force
                    }
                } -ArgumentList $resolvedRemoteStagingPath

                $param = @{
                    ToSession   = $Session
                    Path        = "$($StagingFolderPath)/$($module.Name)_$($module.Version)*"
                    Destination = $ResolvedRemoteStagingPath
                    Force       = $true
                }
                Copy-Item @param | Out-Null
            }
            else
            {
                Write-Verbose 'The File is already present remotely.'
            }
        }

        # Extract missing modules on remote node to PSModulePath
        Write-Verbose "Expanding '$resolvedRemoteStagingPath/*.zip' to '$env:CommonProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)'."
        Invoke-Command -Session $Session -ScriptBlock {
            param (
                [Parameter()]
                $MissingModules,
                [Parameter()]
                $PathToZips
            )
            foreach ($module in $MissingModules)
            {
                $fileName = "$($module.Name)_$($module.version).zip"
                Write-Verbose "Expanding '$PathToZips/$fileName' to '$Env:CommonProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)'."
                Expand-Archive -Path "$PathToZips/$fileName" -DestinationPath "$Env:ProgramW6432\WindowsPowerShell\Modules\$($Module.Name)\$($module.version)" -Force
            }
        } -ArgumentList $missingModules, $resolvedRemoteStagingPath
    }
}
