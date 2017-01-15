function Publish-DscConfiguration {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $DscBuildOutputConfiguration,

        [string]
        $PullServerWebConfig = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config",

        [Parameter(
            Mandatory
        )]
        [Switch]
        $BuildConfigurations
    )

    if ( $BuildConfigurations ) {

        Write-Verbose 'Publishing Configuration MOFs from '
        Write-Verbose "`t$DscBuildOutputConfiguration"
        if ($pscmdlet.shouldprocess("$DscBuildOutputConfiguration")) {
            Get-ChildItem -Path (join-path $DscBuildOutputConfiguration '*.mof') |
                foreach-object {
                    Write-Verbose "Publishing $($_.name)";
                    Publish-MOFToPullServer -FullName $_.FullName -PullServerWebConfig $PullServerWebConfig
                }
        }
    }
    else {
        Write-Warning "Skipping publishing configurations."
    }
}