function Get-StandardCimType
{
    <#
    .SYNOPSIS
        Retrieves the standard CIM types and their corresponding .NET types.

    .DESCRIPTION
        The Get-StandardCimType function retrieves a hashtable of standard Common Information Model (CIM) types and their corresponding .NET types.
        This function is useful for mapping CIM types to .NET types when working with DSC resources.

    .EXAMPLE
        $cimTypes = Get-StandardCimType
        This example retrieves the standard CIM types and their corresponding .NET types.

    .OUTPUTS
        System.Collections.Hashtable
            A hashtable containing the standard CIM types as keys and their corresponding .NET types as values.

    .NOTES
        This function is used internally by other functions such as Get-CimType and Write-CimProperty to map CIM types to .NET types.
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param ()

    $types = @{
        Boolean               = 'System.Boolean'
        UInt8                 = 'System.Byte'
        SInt8                 = 'System.SByte'
        UInt16                = 'System.UInt16'
        SInt16                = 'System.Int16'
        UInt32                = 'System.UInt32'
        SInt32                = 'System.Int32'
        UInt64                = 'System.UInt64'
        SInt64                = 'System.Int64'
        Real32                = 'System.Single'
        Real64                = 'System.Double'
        Char16                = 'System.Char'
        DateTime              = 'System.DateTime'
        String                = 'System.String'
        Reference             = 'Microsoft.Management.Infrastructure.CimInstance'
        Instance              = 'Microsoft.Management.Infrastructure.CimInstance'
        BooleanArray          = 'System.Boolean[]'
        UInt8Array            = 'System.Byte[]'
        SInt8Array            = 'System.SByte[]'
        UInt16Array           = 'System.UInt16[]'
        SInt16Array           = 'System.Int16[]'
        UInt32Array           = 'System.UInt32[]'
        SInt32Array           = 'System.Int32[]'
        UInt64Array           = 'System.UInt64[]'
        SInt64Array           = 'System.Int64[]'
        Real32Array           = 'System.Single[]'
        Real64Array           = 'System.Double[]'
        Char16Array           = 'System.Char[]'
        DateTimeArray         = 'System.DateTime[]'
        StringArray           = 'System.String[]'

        MSFT_Credential       = 'System.Management.Automation.PSCredential'
        'MSFT_KeyValuePair[]' = 'System.Collections.Hashtable'
        MSFT_KeyValuePair     = 'System.Collections.Hashtable'
    }

    $types.GetEnumerator() | ForEach-Object {
        $type = $_.Value -as [type]

        if ($null -eq $type)
        {
            Write-Error -Message "Failed to load CIM Types. The type '$($_.Value)' could not be resolved."
        }

        [PSCustomObject]@{
            CimType    = $_.Key
            DotNetType = $_.Value
        }
    }
}
