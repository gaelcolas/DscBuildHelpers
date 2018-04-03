function Assert-DscModuleResourceIsValid
{
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $DscResources
    )

    begin
    {
        Write-Verbose "Testing for valid resources."
        $FailedDscResources = @()
    }

    process
    {
        foreach($DscResource in $DscResources) {
            $FailedDscResources += Get-FailedDscResource -DscResource $DscResource
        }
    }

    end
    {
        if ($FailedDscResources.Count -gt 0)
        {
            Write-Verbose "Found failed resources."
            foreach ($resource in $FailedDscResources)
            {

                Write-Warning "`t`tFailed Resource - $($resource.Name) ($($resource.Version))"
            }

            throw "One or more resources is invalid."
        }
    }
}