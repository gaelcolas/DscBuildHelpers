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
    ResourceName = 'File'
    ExecutionName = 'Execution_Name'
    Properties = @{
        DestinationPath = 'C:\thing.txt'
        Contents = 'Hello World!'
    }
}



<#
    The following variables are for Pester tests:
    - **ExpectedResource**: what the DSC Resource should look like, when it's create by Get-DscSplattedResource
    - **ExpectedMofContains**: a few lines that should be in the MOF file that this resource generates.
#>
$ExpectedResource = @'
$Properties = @{
    DestinationPath = ('"C:\\thing.txt"' | ConvertFrom-Json);
    Contents = ('"Hello World!"' | ConvertFrom-Json);
}

File Execution_Name {
    DestinationPath = $Properties.DestinationPath
    Contents = $Properties.Contents
}
'@



$ExpectedMofContains = @(
    @{content = 'instance of MSFT_FileDirectoryConfiguration as $MSFT_FileDirectoryConfiguration1ref'}
    @{content = 'ModuleName = "PSDesiredStateConfiguration";'}
    @{content = 'ConfigurationName = "Demo_Configuration";'}
    @{content = 'ResourceID = "[File]Execution_Name";'}
    @{content = 'DestinationPath = "C:\\thing.txt";'}
    @{content = 'Contents = "Hello World!";'}
)