function Publish-DscToolModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [parameter(
            Mandatory
        )]
        $DscBuildOutputTools,

        [string]
        $DscBuildPublishToolsLocation = $(Join-Path -Path $PSHome -ChildPath Modules),

        $ExcludeFolders = @('.g*','.hg')
    )

    $ParametersToPass = $PSBoundParameters
    $null = $ParametersToPass.Remove('DscBuildOutputTools')
    $null = $ParametersToPass.Remove('DscBuildPublishToolsLocation')

    $ParametersToPass['DscBuildSourceTools'] = $DscBuildOutputTools
    $ParametersToPass['DscBuildOutputTools'] = $DscBuildPublishToolsLocation
    Copy-CurrentDscTools @ParametersToPass
}