function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key1,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key2,

        [Parameter(Mandatory = $true)]
        [System.String]
        $String1,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Strings1,

        [Parameter()]
        [bool]
        $Bool1,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present'
    )

    return @{}
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key1,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key2,

        [Parameter(Mandatory = $true)]
        [System.String]
        $String1,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Strings1,

        [Parameter()]
        [bool]
        $Bool1,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present'
    )
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key1,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key2,

        [Parameter(Mandatory = $true)]
        [System.String]
        $String1,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Strings1,

        [Parameter()]
        [bool]
        $Bool1,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present'
    )

    return $true
}
