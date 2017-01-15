function Publish-DscResourceModule {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $DscBuildOutputResources,

        [io.FileInfo]
        $PullServerWebConfig = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config",
        
        [Switch]
        $BuildResources
    )
    Begin
    {
        if ($BuildResources -and ! (Test-Path $PullServerWebConfig) ) {
            if ($PSBoundParameters.ContainsKey('ErrorAction') -and $PSBoundParameters['ErrorAction'] -ne 'SilentlyContinue') {
                Throw "Could not find the Web.config of the pull Server at $PullServerWebConfig"
            }
            else {
                Write-Verbose -Message "Could not find the Web.config of the pull Server at $PullServerWebConfig"
            }
            return
        }

        $webConfigXml = [xml](Get-Content -Raw -Path $PullServerWebConfig)
        $configXElement = $webConfigXml.SelectNodes("//appSettings/add[@key = 'ConfigurationPath']")
        $OutputFolderPath =  $configXElement.Value
    }

    Process {
        if ( $BuildResources ) {
            Write-Verbose 'Moving Processed Resource Modules from '
            Write-Verbose "`t$DscBuildOutputResources to"
            Write-Verbose "`t$OutputFolderPath"

            if ($pscmdlet.shouldprocess("copy $DscBuildOutputResources to $OutputFolderPath")) {
                Get-ChildItem -Path $DscBuildOutputResources -Include @('*.zip','*.checksum') |
                    Copy-Item -Destination $OutputFolderPath -Force
            }
        }
    }
    
}