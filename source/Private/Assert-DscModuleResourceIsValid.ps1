function Assert-DscModuleResourceIsValid
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $DscResources
    )

    begin
    {
        Write-Verbose 'Testing for valid resources.'
        $failedDscResources = @()
    }

    process
    {
        foreach ($DscResource in $DscResources)
        {
            $failedDscResources += Get-FailedDscResource -DscResource $DscResource
        }
    }

    end
    {
        if ($failedDscResources.Count -gt 0)
        {
            Write-Verbose 'Found failed resources.'
            foreach ($resource in $failedDscResources)
            {
                Write-Warning "`t`tFailed Resource - $($resource.Name) ($($resource.Version))"
            }

            throw 'One or more resources is invalid.'
        }
    }
}
