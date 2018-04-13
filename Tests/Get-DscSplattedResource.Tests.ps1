$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$hereParent = Split-Path -Parent $here

$FunctionPath = "$(Split-Path -Parent $here)\DscBuildHelpers\Public\${sut}"
$FunctionName = ([IO.FileInfo] $sut).BaseName

# Make function a global function for testing purposes ...
New-Item -ItemType 'Directory' "${hereParent}\.temp" -Force -ErrorAction 'SilentlyContinue' | Out-Null
Copy-Item $FunctionPath "${hereParent}\.temp" -Force
$FunctionPathTemp = Get-Item "${hereParent}\.temp\$sut"
$FunctionTempContent = Get-Content $FunctionPathTemp
$FunctionTempContent = $FunctionTempContent | ForEach-Object {
    if ($_.StartsWith('function '))
    {
        $_.Replace('function ', 'function global:')
    }
    else
    {
        $_
    }
}
$FunctionTempContent | Out-File -Encoding 'ascii' -LiteralPath $FunctionPathTemp



function Invoke-DscCleanup
{
    #Remove all mof files (pending,current,backup,MetaConfig.mof,caches,etc)
    Remove-Item 'C:\windows\system32\Configuration\*.mof*' -Force -ErrorAction 'Ignore'
    #Kill the LCM/DSC processes
    Get-Process 'wmi*' | Where-Object { $_.modules.ModuleName -like "*DSC*" } | Stop-Process -Force
}



Describe $sut {
    Context 'Importing' {
        It 'Imports without errors' {
            { . $FunctionPathTemp -Scope 'Script' } | Should Not Throw
        }


        It 'Function should exist' {
            Get-Command $FunctionName | Should Not BeNullOrEmpty
        }
    }


    foreach ($FunctionTest in (Get-ChildItem ".\Examples\${FunctionName}.*.ps1"))
    {
        $Get_DscSplattedResource = $null
        $ExpectedResource = $null
        $ExpectedMofContains = $null


        Context $FunctionTest.Name {
            . $FunctionTest.FullName

            Write-Verbose "Get_DscSplattedResource: $($Get_DscSplattedResource | ConvertTo-Json)"
            Write-Verbose "ExpectedResource:`n${ExpectedResource}"
            Write-Verbose "ExpectedMofContains:`n${ExpectedMofContains}"


            It 'Get_DscSplattedResource should be set' {
                $Get_DscSplattedResource | Should Not BeNullOrEmpty
            }


            It 'Get_DscSplattedResource type' {
                $Get_DscSplattedResource | Should BeOfType 'System.Collections.Hashtable'
            }


            It 'Get_DscSplattedResource should not contain *NoInvoke*' {
                $Get_DscSplattedResource.Keys | Should Not Contain 'NoInvoke'
            }


            It 'ExpectedResource should be set' {
                $ExpectedResource | Should Not BeNullOrEmpty
            }


            It 'ExpectedResource type' {
                $ExpectedResource | Should BeOfType 'System.String'
            }


            It 'ExpectedMofContains should be set' {
                $ExpectedMofContains | Should Not BeNullOrEmpty
            }


            It 'ExpectedMofContains type' {
                ,$ExpectedMofContains | Should BeOfType 'System.Object[]'
            }

            $Error_NotInConfiguration_ResourceNameNotRecognized = "The term '$($Get_DscSplattedResource.ResourceName)' is not recognized"


            It 'Get_DscSplattedResource splat it to Invoke; should throw' {
                # we're not in a configuration, so we expect this to throw ...
                { Get-DscSplattedResource @Get_DscSplattedResource } | Should Throw $Error_NotInConfiguration_ResourceNameNotRecognized
            }


            It 'Get_DscSplattedResource splat it to Invoke; should not throw' {
                # we're not in a configuration, so we expect this to throw ...
                {
                    configuration Demo_Configuration {
                        Node 'localhost' {
                            Get-DscSplattedResource @Get_DscSplattedResource
                        }
                    }
                } | Should Not Throw
            }

            $Get_DscSplattedResource.NoInvoke = $true


            It 'Get_DscSplattedResource splat it to NoInvoke; should not throw' {
                # we're not in a configuration, but we''re not invoking ... so we don't expect this to throw ...
                { $script:DscSplattedResource = Get-DscSplattedResource @Get_DscSplattedResource } | Should Not Throw
            }

            # $DscSplattedResource = Get-DscSplattedResource @Get_DscSplattedResource


            It 'Get_DscSplattedResource splat it to NoInvoke; is *generally* what is expected' {
                # Yes, we are jummbling around the orders, but so will powershell (hashtable)
                # As long as we have all the same lines: **good nuff**
                $Compare_Object = @{
                    ReferenceObject = $DscSplattedResource.ToString().Trim().Split("`r").Trim() | Where-Object { -not [String]::IsNullOrEmpty($_) } | Sort-Object
                    DifferenceObject = $ExpectedResource.Trim().Split("`r").Trim() | Where-Object { -not [String]::IsNullOrEmpty($_) } | Sort-Object
                }
                Write-Debug "Compare-Object: $($Compare_Object | ConvertTo-Json)"
                Compare-Object @Compare_Object | Should BeNullOrEmpty
            }


            It 'Get_DscSplattedResource splat it to NoInvoke; in config should not throw' {
                # we're not in a configuration, but we''re not invoking ... so we don't expect this to throw ...
                {
                    configuration Demo_Configuration {
                        Node 'localhost' {
                            Get-DscSplattedResource @Get_DscSplattedResource
                        }
                    }
                } | Should Not Throw
            }


            It 'Build Configuration' {
                $Resource = Get-DscSplattedResource @Get_DscSplattedResource
                $script:Demo_Configuration = [scriptblock]::Create(@"
configuration Demo_Configuration {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost' {
        $($Resource.ToString())
    }
}
"@)
                { $Demo_Configuration | Invoke-Expression } | Should Not Throw
            }


            Push-Location "${hereParent}\.temp"

            It 'Invoke Configuration' {
                $Demo_Configuration | Invoke-Expression
                ($script:MofFiles = Demo_Configuration) | Should BeOfType 'System.IO.FileInfo'
            }

            Pop-Location


            foreach ($MofFile in $script:MofFiles.FullName)
            {
                $MofFileContent = (Get-Content $MofFile).Trim()
                It 'MOF contains: <content>' -TestCases $ExpectedMofContains {
                    param( $content )
                    $MofFileContent | Should Contain $content
                }
            }


            if ($env:CI)
            {
                It 'Apply Configuration' {
                    { Start-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -Wait -Force -ErrorAction 'Stop' } | Should Not Throw
                }
            }
            else
            {
                Write-Warning "Skipping 'Apply Configuration'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
            }


            if ($env:CI)
            {
                $tested = Test-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -ErrorAction 'Ignore'
                It 'Test Configuration' {
                    { Test-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -ErrorAction 'Stop' } | Should Not Throw
                }
            }
            else
            {
                Write-Warning "Skipping 'Test Configuration'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
            }


            if ($env:CI)
            {
                It 'Test Configuration In Desired State: True' {
                    # We have applied the Configuration, so this should be true.
                    $tested.InDesiredState | Should Be $TRUE
                }
            }
            else
            {
                Write-Warning "Skipping 'Test Configuration In Desired State: True'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
            }


            if ($Get_DscSplattedResource.ResourceName -ne 'Script')
            {
                $Get_DscSplattedResource.Properties.Ensure = 'Absent'

                It 'Build Configuration (Absent)' {
                    $Resource = Get-DscSplattedResource @Get_DscSplattedResource
                    $script:Demo_Configuration = [scriptblock]::Create(@"
configuration Demo_Configuration {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost' {
        $($Resource.ToString())
    }
}
"@)
                    { $Demo_Configuration | Invoke-Expression } | Should Not Throw
                }


                Push-Location "${hereParent}\.temp"

                It 'Invoke Configuration (Absent)' {
                    $Demo_Configuration | Invoke-Expression
                    Demo_Configuration | Should BeOfType 'System.IO.FileInfo'
                }

                Pop-Location


                if ($env:CI)
                {
                    It 'Apply Configuration (Absent)' {
                        { Start-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -Wait -Force -ErrorAction 'Stop' } | Should Not Throw
                    }
                }
                else
                {
                    Write-Warning "Skipping 'Apply Configuration'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
                }


                if ($env:CI)
                {
                    $tested = Test-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -ErrorAction 'Ignore'
                    It 'Test Configuration (Absent)' {
                        { Test-DscConfiguration "${hereParent}\.temp\Demo_Configuration" -ErrorAction 'Stop' } | Should Not Throw
                    }
                }
                else
                {
                    Write-Warning "Skipping 'Test Configuration'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
                }


                if ($env:CI)
                {
                    It 'Test Configuration (Absent) In Desired State: True' {
                        # We have applied the Configuration, so this should be true.
                        $tested.InDesiredState | Should Be $TRUE
                    }
                }
                else
                {
                    Write-Warning "Skipping 'Test Configuration In Desired State: True'; don't want to apply DSC to dev machines. Set ```$env:CI = `$true`` if you want to test on this machine."
                }
            }
        }

        Invoke-DscCleanup
    }
}