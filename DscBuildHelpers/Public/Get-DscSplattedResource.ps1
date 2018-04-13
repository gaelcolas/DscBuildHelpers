<#
    .SYNOPSIS
        Create a DSC resource configuration based on passed parameters.

    .DESCRIPTION
        Create a DSC resource configuration based on passed parameters.

    .PARAMETER ResourceName
        The name of a Resource or Composite Resource; such as:
        - File: https://docs.microsoft.com/en-us/powershell/dsc/fileresource
        - Registry: https://docs.microsoft.com/en-us/powershell/dsc/registryresource
        - Script: https://docs.microsoft.com/en-us/powershell/dsc/scriptresource
        - OneDrive: https://github.com/UNT-CAS/OneDriveDsc

    .PARAMETER ExecutionName
        This is the unique name of excution of the resource.
        For example, `Execution_Name` in the following file resource example:

        ```powershell
            File Execution_Name
            {
                DestinationPath = 'C:\thing.txt'
                Contents = 'Hello World!'
            }
        ```

    .PARAMETER Usings
        In a script resource (and maybe others) the code to be executed on the DSC client/node may need a global constant made available to it.
        This is accomplished with the `using` scope.
        This parameter contains all of the global contants that need to be made available to the `using` scope.
    
    .PARAMETER Properties
        This parameter contains all of the properties for the resource that we're building.

    .PARAMETER NoInvoke
        This prevents invoking the *compiled resource* within this function, and instead returns the final resource so that it may be invoked in a parent scope.

        Not invoking within this function will likely solve scope issues; such as not being able to see dependent (`DependsOn`) resources.

    .Example
        # This will *invoke* a File Resource identical to the example given in the *ExecutionName* Parameter, shown above.

        $Get_SplattedResource = @{
            ResourceName = 'File'
            ExecutionName = 'Execution_Name'
            Properties = @{
                DestinationPath = 'C:\thing.txt'
                Contents = 'Hello World!'
            }
        }

        Get-DscSplattedResource @Get_DscSplattedResource
    .Example
        # This is a more complicated Script resource that will return the compiled resource for invocation.

        $InstanceName = 'FooBar'
        $DependsOn = '[File]Execution_Name'
        $RegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\${InstanceName}"

        $Get_DscSplattedResource = @{
            ResourceName = 'Script'
            ExecutionName = $InstanceName
            Usings = @{
                RegKey = "Registry::${RegKey}"
            }
            Properties = @{
                GetScript = {
                    return @{ Result = "RegKeyExists: $(Test-Path $using:RegKey)" }
                }
                SetScript = {
                    Remove-Item -LiteralPath $using:RegKey -Force
                }
                TestScript = {
                    return (-not (Test-Path $using:RegKey))
                }
                DependsOn = $DependsOn
            }
            NoInvoke = $true
        }

        $DscSplattedResource = Get-DscSplattedResource @Get_DscSplattedResource
        $DscSplattedResource.Invoke()

        #####################################################################
        # This is what the compiled resource looks like ...
        # 
        # This example lies a little to keep things simpler.
        # A full example will be made available in the Pester tests.
        #####################################################################

        $RegKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\FooBar'

        Script FooBar {
            GetScript = {
                return @{ Result = "RegKeyExists: $(Test-Path $using:RegKey)" }
            }
            SetScript = {
                Remove-Item -LiteralPath $using:RegKey -Force
            }
            TestScript = {
                return (-not (Test-Path $using:RegKey))
            }
            DependsOn = @('[File]Execution_Name')
        }
#>
function Get-DscSplattedResource
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName
        ,
        [Parameter(Mandatory = $true)]
        [string]
        $ExecutionName
        ,
        [Parameter()]
        [hashtable]
        $Usings
        ,
        [Parameter(Mandatory = $true)]
        [hashtable]
        $Properties
        ,
        [Parameter()]
        [switch]
        $NoInvoke
    )
    Write-Verbose "[DscBuildHelpers] Get-DscSplattedResource: $($PSBoundParameters | ConvertTo-Json -Compress)"

    $StringBuilder = [System.Text.StringBuilder]::new()


    $StringBuilder.AppendLine("`$Properties = @{") | Out-Null
    foreach ($Property in $Properties.GetEnumerator())
    {
        if ($Property.Value -is [scriptblock])
        {
            $StringBuilder.AppendLine("    $($Property.Name) = {") | Out-Null
            $StringBuilder.AppendLine($Property.Value.ToString()) | Out-Null
            $StringBuilder.AppendLine('    }') | Out-Null
        }
        else
        {
            $StringBuilder.AppendLine("    $($Property.Name) = ('$($Property.Value | ConvertTo-Json -Compress)' | ConvertFrom-Json);") | Out-Null
        }
    }
    $StringBuilder.AppendLine("}") | Out-Null
    $StringBuilder.AppendLine() | Out-Null


    if ($Usings)
    {
        foreach ($u in $Usings.GetEnumerator())
        {
            if ($u -is [scriptblock])
            {
                $StringBuilder.AppendLine("`$$($u.Name) = {") | Out-Null
                $StringBuilder.AppendLine($u.Value.ToString()) | Out-Null
                $StringBuilder.AppendLine("}") | Out-Null
            }
            else
            {
                $StringBuilder.AppendLine("`$$($u.Name) = '$($u.Value | ConvertTo-Json -Compress)' | ConvertFrom-Json") | Out-Null
            }
        }
        $StringBuilder.AppendLine() | Out-Null
    }


    $StringBuilder.AppendLine("${ResourceName} ${ExecutionName} {") | Out-Null
    foreach ($PropertyName in $Properties.Keys)
    {
        $StringBuilder.AppendLine("    ${PropertyName} = `$Properties.$PropertyName") | Out-Null
    }
    $StringBuilder.AppendLine("}") | Out-Null
    Write-Verbose "[DscBuildHelpers] Get-DscSplattedResource: StringBuilder:`n$($StringBuilder.ToString())"


    if ($NoInvoke)
    {
        Write-Verbose "[DscBuildHelpers] Get-DscSplattedResource: Returning StringBuilder"
        return [scriptblock]::Create($StringBuilder.ToString())
    }
    else
    {
        Write-Verbose "[DscBuildHelpers] Get-DscSplattedResource: Invoking StringBuilder"
        [scriptblock]::Create($StringBuilder.ToString()).Invoke()
    }
}