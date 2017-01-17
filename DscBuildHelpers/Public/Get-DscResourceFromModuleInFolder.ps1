function Get-DscResourceFromModuleInFolder
{
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        $ModuleFolder,
        
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSModuleInfo[]]
        $Modules
        
    )
    Begin {
        $oldPSModulePath = $Env:PSmodulePath
        $Env:PSmodulePath = $ModuleFolder
        Write-Verbose "Retrieving all resources for $ModuleFolder."
        $AllDscResource = Get-DscResource
        $Env:PSmodulePath = $oldPSModulePath
    }
    Process {
        
        Write-Verbose "Filtering the $($AllDscResource.Count) resources."
        Write-Debug ('Resources {0}' -f ($AllDscResource | Format-Table -AutoSize | out-string))
        $AllDscResource.Where{
                    $isResourceInModulesToPublish = Foreach ($Module in $Modules) {
                        if ( $null -eq $_.Module ) {
                            Write-Debug "Excluding resource $($_.Name) without Module"
                            Return $false
                        }
                        elseif ( !(compare-object $_.Module $Module -Property ModuleType,Version,Name) ) {
                            Write-Debug "Resource $($_.Name) matches one of the supplied Modules."
                            Return $true
                        }
                    }
                    if (!$isResourceInModulesToPublish) {
                        Write-Debug "`tExcluding $($_.Name) $($_.Version)"
                        Return $false
                    }
                    else {
                        Write-Debug "`tIncluding $($_.Name) $($_.Version)"
                        Return $true
                    }
                }
    }
}