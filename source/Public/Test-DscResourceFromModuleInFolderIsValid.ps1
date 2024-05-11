function Test-DscResourceFromModuleInFolderIsValid
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]
        $ModuleFolder,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.PSModuleInfo[]]
        [AllowNull()]
        $Modules
    )

    process
    {
        foreach ($module in $Modules)
        {
            $Resources = Get-DscResourceFromModuleInFolder -ModuleFolder $ModuleFolder -Modules $module

            $Resources.Where{ $_.ImplementedAs -eq 'PowerShell' } | Assert-DscModuleResourceIsValid
        }
    }
}
