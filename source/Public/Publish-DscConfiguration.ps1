function Publish-DscConfiguration
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DscBuildOutputConfigurations,

        [Parameter()]
        [string]
        $PullServerWebConfig = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"
    )

    process
    {
        Write-Verbose "Publishing Configuration MOFs from '$DscBuildOutputConfigurations'."

        Get-ChildItem -Path (Join-Path -Path $DscBuildOutputConfigurations -ChildPath '*.mof') |
            ForEach-Object {
                if (-not (Test-Path -Path $PullServerWebConfig))
                {
                    Write-Warning "The Pull Server configg '$PullServerWebConfig' cannot be found."
                    Write-Warning "`t Skipping Publishing Configuration MOFs"
                }
                elseif ($PSCmdlet.shouldprocess($_.BaseName))
                {
                    Write-Verbose -Message "Publishing $($_.Name)"
                    Publish-MofToPullServer -FullName $_.FullName -PullServerWebConfig $PullServerWebConfig
                }
            }
    }
}
