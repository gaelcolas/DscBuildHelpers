function Copy-CurrentDscTools {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $DscBuildSourceTools,

        [parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $DscBuildOutputTools,

        [string[]]
        $ExcludedFolder = @('.g*','.hg')
    )

    Write-Verbose "Pushing tools modules from $DscBuildSourceTools to $DscBuildOutputTools."

    if ($pscmdlet.shouldprocess("$DscBuildSourceTools to $DscBuildSourceTools")) {
        Get-ChildItem -Path $DscBuildSourceTools -exclude $ExcludedFolder |
             Test-ModuleVersion -Destination $DscBuildOutputTools |
              Copy-Item -Destination $DscBuildOutputTools -Recurse -Force
    }
}