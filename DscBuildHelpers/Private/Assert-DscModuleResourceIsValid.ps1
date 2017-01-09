function Assert-DscModuleResourceIsValid
{
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline)]
        [IO.FileSystemInfo]
        $InputObject
    )

    begin
    {
        Write-Verbose "Testing for valid resources."
        $FailedDscResources = @()
    }

    process
    {
        $FailedDscResources += Get-FailedDscResource -AllModuleResources (Get-DscResourceForModule -InputObject $InputObject)
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