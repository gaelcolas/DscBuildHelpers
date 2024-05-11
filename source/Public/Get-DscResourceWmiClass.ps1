function Get-DscResourceWmiClass
{
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
        #The WMI Class name search for. Supports wildcards.
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Name')]
        [string]
        $Class
    )

    begin
    {
        $dscNamespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
    }

    process
    {
        Get-WmiObject -Namespace $dscNamespace -List @PSBoundParameters
    }
}
