function Assert-DscModuleResourceIsValid
{
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline)]
        [PSModuleInfo]
        $Module
    )

    begin
    {
        Write-Verbose "Testing for valid resources."
        $FailedDscResources = @()
    }

    process
    {
        $FailedDscResources += Get-FailedDscResource -AllModuleResources (Get-DscResourceForModule -Module $Module)
    }

    end
    {
        if ($FailedDscResources.Count -gt 0)
        {
            Write-Verbose "Found failed resources."
            foreach ($resource in $FailedDscResources)
            {

                Write-Warning "`t`tFailed Resource - $($resource.Name) ($($resource.ParentPath))"
            }

            throw "One or more resources is invalid."
        }
    }
}