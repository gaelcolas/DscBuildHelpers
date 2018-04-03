function Get-DscFailedResource {
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo[]]
        $DscResource
    )

    Process {
        foreach ($resource in $DscResource) {
            if ($resource.Path) {
                $resourceNameOrPath = Split-Path $resource.Path -Parent
            }
            else {
                $resourceNameOrPath = $resource.Name
            }
            
            if (-not (Test-xDscResource -Name $resourceNameOrPath)) {
                Write-Warning "`tResources $($_.name) is invalid."
                $resource
            }
            else {
                Write-Verbose ('DSC Resource Name {0} {1} is Valid' -f $resource.Name, $resource.Version)
            }
        }
    }
}