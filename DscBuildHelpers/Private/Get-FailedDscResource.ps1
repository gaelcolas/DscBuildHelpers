function Get-FailedDscResource
{
    [cmdletbinding()]
    param ($AllModuleResources)

    foreach ($resource in $AllModuleResources)
    {
        if ($resource.Path)
        {
            $resourceNameOrPath = Split-Path $resource.Path -Parent
        }
        else
        {
            $resourceNameOrPath = $resource.Name
        }

        if (-not (Test-xDscResource -Name $resourceNameOrPath))
        {
            Write-Warning "`tResources $($_.name) is invalid."
            $resource
        }
    }
}