<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Push-DscConfiguration {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact='High'
    )]
    [Alias()]
    [OutputType([void])]
    Param (
        # Param1 help description
        [Parameter(Mandatory,
                    Position=0
                   ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Runspaces.PSSession] 
        $Session,
        
        # Param2 help description
        [Parameter()]
        [Alias('MOF','Path')]
        [System.IO.FileInfo]
        $ConfigurationDocument,
        
        # Param3 help description
        [Parameter()]
        [psmoduleinfo[]]
        $WithModule,

        [Parameter(
            ,Position = 1
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        [Alias('DscBuildOutputModules')]
        $StagingFolderPath = "$Env:TMP\DSC\BuildOutput\modules\",

        [Parameter(
            ,Position = 3
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        $RemoteStagingPath = '$Env:TMP\DSC\modules\',

        [Parameter(
            ,Position = 4
            ,ValueFromPipelineByPropertyName
            ,ValueFromRemainingArguments
        )]
        [switch]
        $Force
    )
    
   
    process {
        if ($pscmdlet.ShouldProcess($Session.ComputerName, "Applying MOF $ConfigurationDocument")) {
            if ($WithModule) {
                Push-DscModuleToNode -Module $WithModule -StagingFolderPath $StagingFolderPath -RemoteStagingPath $RemoteStagingPath -Session $Session
            }

            Write-Verbose "Removing previously pushed configuration documents"
            $ResolvedRemoteStagingPath = Invoke-Command -Session $Session -ScriptBlock {
                $ResolvedStagingPath = $ExecutionContext.InvokeCommand.ExpandString($Using:RemoteStagingPath)
                $null = Get-item "$ResolvedStagingPath\*.mof" | Remove-Item -force -ErrorAction SilentlyContinue
                if (!(Test-Path $ResolvedStagingPath)) {
                    mkdir -Force $ResolvedStagingPath -ErrorAction Stop
                }
                Write-Output $ResolvedStagingPath
            } -ErrorAction Stop

            $RemoteConfigDocumentPath = [io.path]::Combine(
                $ResolvedRemoteStagingPath,
                'localhost.mof'
            )

            Copy-Item -ToSession $Session -Path $ConfigurationDocument -Destination $RemoteConfigDocumentPath -Force -ErrorAction Stop

            Write-Verbose "Attempting to apply $RemoteConfigDocumentPath on $($session.ComputerName)"
            Invoke-Command -Session $Session -scriptblock {
                Start-DscConfiguration -Wait -Force -Path $Using:ResolvedRemoteStagingPath -Verbose -ErrorAction Stop
            }
        }
    }
}