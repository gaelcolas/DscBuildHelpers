function Get-DscResourceWmiClass {
    <#
        .Synopsis
            Retrieves WMI classes from the DSC namespace.
        .Description
            Retrieves WMI classes from the DSC namespace.
        .Example
            Get-DscResourceWmiClass -Class tmp*
        .Example
            Get-DscResourceWmiClass -Class 'MSFT_UserResource'
    #>
    param (
        #The WMI Class name search for.  Supports wildcards.
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string]
        $Class
    )
    begin {
        $DscNamespace = "root/Microsoft/Windows/DesiredStateConfiguration"
    }
    process {
        Get-wmiobject -Namespace $DscNamespace -list @psboundparameters
    }
}