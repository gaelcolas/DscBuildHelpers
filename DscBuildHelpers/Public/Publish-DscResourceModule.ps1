function Publish-DscResourceModule {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $DscBuildOutputModules,

        [io.FileInfo]
        $PullServerWebConfig = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer\web.config"
    )
    Begin
    {
        if ( !(Test-Path $PullServerWebConfig) ) {
            if ($PSBoundParameters['ErrorAction'] -eq 'SilentlyContinue') {
                Write-Warning -Message "Could not find the Web.config of the pull Server at $PullServerWebConfig"
            }
            else {
                Throw "Could not find the Web.config of the pull Server at $PullServerWebConfig"
            }
            return
        }
        else {
            $webConfigXml = [xml](Get-Content -Raw -Path $PullServerWebConfig)
            $configXElement = $webConfigXml.SelectNodes("//appSettings/add[@key = 'ConfigurationPath']")
            $OutputFolderPath =  $configXElement.Value
        }
    }

    Process {
        if ($OutputFolderPath) {
            Write-Verbose 'Moving Processed Resource Modules from '
            Write-Verbose "`t$DscBuildOutputModules to"
            Write-Verbose "`t$OutputFolderPath"

            if ($pscmdlet.shouldprocess("copy $DscBuildOutputModules to $OutputFolderPath")) {
                Get-ChildItem -Path $DscBuildOutputModules -Include @('*.zip','*.checksum') |
                    Copy-Item -Destination $OutputFolderPath -Force
            }
        }
    }
    
}