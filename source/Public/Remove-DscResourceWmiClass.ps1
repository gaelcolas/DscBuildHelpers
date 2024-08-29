<#
    .Synopsis
        Removes a WMI class from the DSC namespace.
    .Description
        Removes a WMI class from the DSC namespace.
    .Example
        Get-DscResourceWmiClass -Class tmp* | Remove-DscResourceWmiClass
    .Example
        Remove-DscResourceWmiClass -Class 'tmpD460'
#>
function Remove-DscResourceWmiClass
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '', Justification = 'Not possible via CIM')]
    [CmdletBinding()]
    param (
        #The WMI Class name to remove.  Supports wildcards.
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Name')]
        [string]
        $ResourceType
    )

    begin
    {
        $dscNamespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
    }

    process
    {
        #Have to use WMI here because I can't find how to delete a WMI instance via the CIM cmdlets.
        (Get-WmiObject -Namespace $dscNamespace -List -Class $ResourceType).psbase.Delete()
    }
}
