function Push-DscConfiguration
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        [Parameter()]
        [Alias('MOF', 'Path')]
        [System.IO.FileInfo]
        $ConfigurationDocument,

        [Parameter()]
        [System.Management.Automation.PSModuleInfo[]]
        $WithModule,

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true, Position = 1)]
        [Alias('DscBuildOutputModules')]
        $StagingFolderPath = "$Env:TMP\DSC\BuildOutput\modules\",

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true, Position = 3)]
        $RemoteStagingPath = '$Env:TMP\DSC\modules\',

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true, Position = 4)]
        [switch]
        $Force
    )

    process
    {
        if ($PSCmdlet.ShouldProcess($Session.ComputerName, "Applying MOF '$ConfigurationDocument'"))
        {
            if ($WithModule)
            {
                Push-DscModuleToNode -Module $WithModule -StagingFolderPath $StagingFolderPath -RemoteStagingPath $RemoteStagingPath -Session $Session
            }

            Write-Verbose 'Removing previously pushed configuration documents'
            $resolvedRemoteStagingPath = Invoke-Command -Session $Session -ScriptBlock {
                $resolvedStagingPath = $ExecutionContext.InvokeCommand.ExpandString($Using:RemoteStagingPath)
                $null = Get-Item "$resolvedStagingPath\*.mof" | Remove-Item -Force -ErrorAction SilentlyContinue
                if (-not (Test-Path $resolvedStagingPath))
                {
                    mkdir -Force $resolvedStagingPath -ErrorAction Stop
                }
                $resolvedStagingPath
            } -ErrorAction Stop

            $remoteConfigDocumentPath = [System.IO.Path]::Combine($ResolvedRemoteStagingPath, 'localhost.mof')

            Copy-Item -ToSession $Session -Path $ConfigurationDocument -Destination $remoteConfigDocumentPath -Force -ErrorAction Stop

            Write-Verbose "Attempting to apply '$remoteConfigDocumentPath' on '$($session.ComputerName)'"
            Invoke-Command -Session $Session -ScriptBlock {
                Start-DscConfiguration -Wait -Force -Path $Using:resolvedRemoteStagingPath -Verbose -ErrorAction Stop
            }
        }
    }
}
