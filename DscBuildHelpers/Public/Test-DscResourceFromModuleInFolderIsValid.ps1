function Test-DscResourceFromModuleInFolderIsValid {
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [System.io.DirectoryInfo]
        $ModuleFolder,
        
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline
        )]
        [System.Management.Automation.PSModuleInfo[]]
        [AllowNull()]
        $Modules
    )
    
    Process {
        Foreach ($module in $Modules) {
            $Resources = Get-DscResourceFromModuleInFolder -ModuleFolder $ModuleFolder `
                                                          -Modules $module

            $Resources.Where{$_.ImplementedAs -eq 'PowerShell'} | Assert-DscModuleResourceIsValid
        }
    }
}