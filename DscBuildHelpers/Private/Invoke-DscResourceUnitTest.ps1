function Invoke-DscResourceUnitTest {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $DscBuildSourceResources
    )

    if ( Test-BuildResource ) {
        if ($pscmdlet.shouldprocess($DscBuildSourceResources)) {
            Write-Verbose 'Running Resource Unit Tests.'

            $failCount = 0

            foreach ($module in $script:DscBuildParameters.ModulesToPublish)
            {
                $modulePath = Join-Path $DscBuildSourceResources $module
                $result = Invoke-Pester -Path $modulePath -PassThru
                $failCount += $result.FailedCount
            }

            if ($failCount -gt 0)
            {
                throw "$failCount Resource Unit Tests were failed."
            }
        }
    }
}