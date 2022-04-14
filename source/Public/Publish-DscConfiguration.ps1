function Publish-DscConfiguration {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $DscBuildOutputConfigurations,

        [string]
        $PullServerWebConfig = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"
    )
    Process {
        Write-Verbose "Publishing Configuration MOFs from $DscBuildOutputConfigurations"

        
        Get-ChildItem -Path (join-path -Path $DscBuildOutputConfigurations -ChildPath '*.mof') |
            foreach-object {
                if ( !(Test-Path -Path $PullServerWebConfig) ) {
                    Write-Warning "The Pull Server configg $PullServerWebConfig cannot be found."
                    Write-Warning "`t Skipping Publishing Configuration MOFs"
                }
                elseif ($pscmdlet.shouldprocess($_.BaseName)) {
                    Write-Verbose -Message "Publishing $($_.name)"
                    Publish-MOFToPullServer -FullName $_.FullName -PullServerWebConfig $PullServerWebConfig
                }
            }
    }
}