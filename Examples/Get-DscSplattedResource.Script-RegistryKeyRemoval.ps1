<#
    .Synopsis
        This file contains variables used by Pester for Testing; it also serves as a terse usage example.

    .Description
        Pester will take the hashtable below ($Get_DscSplattedResource) and splat into Get-DscSplattedResource.

    .Example
        $Resource = Get-DscSplattedResource @Get_DscSplattedResource
        
        $script:Demo_Configuration = [scriptblock]::Create(@"
        configuration Demo_Configuration {
            Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

            Node 'localhost' {
                $($Resource.ToString())
            }
        }
        "@)
        
        $Demo_Configuration | Invoke-Expression

        Demo_Configuration

    .Notes
        The example looks a bit rough, but I tried several options, and finally got the test block to work like this.
#>
$Get_DscSplattedResource = @{
    ResourceName = 'Script'
    ExecutionName = 'FooBar'
    Usings = @{
        RegKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\FooBar"
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
    }
}



<#
    The following variables are for Pester tests:
    - **ExpectedResource**: what the DSC Resource should look like, when it's create by Get-DscSplattedResource
    - **ExpectedMofContains**: a few lines that should be in the MOF file that this resource generates.
#>
$ExpectedResource = @'
$Properties = @{
    GetScript = {
        return @{ Result = "RegKeyExists: $(Test-Path $using:RegKey)" }
    }
    SetScript = {
        Remove-Item -LiteralPath $using:RegKey -Force
    }
    TestScript = {
        return (-not (Test-Path $using:RegKey))
    }
}

$RegKey = '"Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\FooBar"' | ConvertFrom-Json

Script FooBar {
    GetScript = $Properties.GetScript
    SetScript = $Properties.SetScript
    TestScript = $Properties.TestScript
}
'@



$ExpectedMofContains = @(
    @{content = 'instance of MSFT_ScriptResource as $MSFT_ScriptResource1ref'}
    @{content = 'ModuleName = "PSDesiredStateConfiguration";'}
    @{content = 'ResourceID = "[Script]FooBar";'}
    @{content = 'GetScript = "$RegKey =''Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\FooBar''\n\n\n            return @{ Result = \"RegKeyExists: $(Test-Path $RegKey)\" }\n        \n    ";'}
    @{content = 'SetScript = "$RegKey =''Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\FooBar''\n\n\n            Remove-Item -LiteralPath $RegKey -Force\n        \n    ";'}
    @{content = 'TestScript = "$RegKey =''Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\FooBar''\n\n\n            return (-not (Test-Path $RegKey))\n        \n    ";'}
    @{content = 'ConfigurationName = "Demo_Configuration";'}
)