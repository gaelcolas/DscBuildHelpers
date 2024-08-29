function Get-DscResourceFromModuleInFolder
{
    [CmdletBinding()]
    [OutputType([object[]])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleFolder,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSModuleInfo[]]
        $Modules
    )

    begin
    {
        $oldPSModulePath = $env:PSModulePath
        $env:PSModulePath = $ModuleFolder

        Write-Verbose "Retrieving all resources for '$ModuleFolder'."
        $dscResources = Get-DscResource

        $env:PSModulePath = $oldPSModulePath

        $result = @()
    }

    process
    {
        Write-Verbose "Filtering the $($dscResources.Count) resources."
        Write-Debug ($dscResources | Format-Table -AutoSize | Out-String)

        foreach ($dscResource in $dscResources)
        {
            if ($null -eq $dscResource.Module)
            {
                Write-Debug "Excluding resource '$($dscResource.Name) - $($dscResource.Version)', it is not part of a module."
                continue
            }

            foreach ($module in $Modules)
            {
                if (-not (Compare-Object -ReferenceObject $dscResource.Module -DifferenceObject $Module -Property ModuleType, Version, Name))
                {
                    Write-Debug "Resource $($dscResource.Name) matches one of the supplied Modules."
                    Write-Debug "`tIncluding $($dscResource.Name) $($dscResource.Version)"
                    $result += $dscResource
                }
            }
        }
    }

    end
    {
        $result
    }
}
