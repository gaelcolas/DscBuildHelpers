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
        
        [AllowNull()]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        $ExcludedModules = $null
    )

    Write-Verbose "Pushing tools modules from $DscBuildSourceTools to $DscBuildOutputTools."

    if ($pscmdlet.shouldprocess("$DscBuildSourceTools to $DscBuildSourceTools")) {
        $ModuleFromTools = Get-ModuleFromFolder -ModuleFolder $DscBuildSourceTools -ExcludedModules $ExcludedModules
        $ExistingModules = Get-ModuleFromFolder -ModuleFolder $DscBuildOutputTools -ExcludedModules $ExcludedModules

        $ModuleFromTools.Where{
            Write-Verbose "Checking if Module $($_.Name) is present in $DscBuildOutputTools"
            $IsModulePresent = foreach ($ExistingModule in $ExistingModules) {
                if ( 
                    !(Compare-Object -ReferenceObject $ExistingModule -DifferenceObject $_ -Property Name,Version,Guid)
                   )
                {
                    Write-Verbose "This Module $($_.Name) $($_.Version) exists already in Target"
                    Return $true    
                }
            }
            if ($IsModulePresent) {
                Return $false #Do not copy
            }
            else {
                Return $true
            }
        }.Foreach{
            $ModuleBase = (Split-Path -Path $_.Path -Parent)
            if ($_.ModuleType -eq 'Manifest') {
                $OutModuleBase = [System.IO.Path]::Combine($DscBuildOutputTools, $_.Name, $_.version)
            }
            else {
                $OutModuleBase = [System.IO.Path]::Combine($DscBuildOutputTools, $_.Name)
            }
            Write-Verbose "Copying Module $($_.Name) $($_.Version)"
            Write-Verbose "`tFrom: $ModuleBase"
            Write-Verbose "`tTo:   $OutModuleBase"

            Copy-Item -Path $ModuleBase -Destination $OutModuleBase -Recurse -Force
        }
    }
}