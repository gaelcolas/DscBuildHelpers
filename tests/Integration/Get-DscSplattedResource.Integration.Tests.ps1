BeforeDiscovery {

    $here = $PSScriptRoot
    $modulePath = Resolve-Path -Path $here\Assets\DscResources\ | Select-Object -ExpandProperty Path
    $env:PSModulePath = "$modulePath;$($env:PSModulePath)"
    $dscResources = Get-DscResource -Name MofBased*, ClassBased* -ErrorAction SilentlyContinue

    $skippedDscResources = ''

    Import-Module -Name datum
    Import-Module -Name DscBuildHelpers -Force

    $datum = New-DatumStructure -DefinitionFile $here\Assets\Datum.yml
    $allNodes = Get-Content -Path $here\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

    Write-Host 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
    Initialize-DscResourceMetaInfo -ModulePath $modulePath
    Write-Host 'Done'

    $global:configurationData = @{
        AllNodes = [array]$allNodes
        Datum    = $Datum
    }

    [hashtable[]]$testCases = @()
    $configFiles = $datum.Config | Get-Member -MemberType ScriptProperty | Select-Object -ExpandProperty Name
    foreach ($dscResource in $dscResources)
    {
        foreach ($configFile in $configFiles | Where-Object { $_ -like "$($dscResource.Name)*" })
        {
            $testCases += @{
                DscResourceName = $dscResource.Name
                DscModuleName   = $dscResource.ModuleName
                Skip            = ($dscResource.Name -in $skippedDscResources)
                ConfigPath      = $configFile
            }
        }
    }

    $finalTestCases = @()
    $finalTestCases += @{
        AllDscResources      = $DscResources.Name
        FilteredDscResources = $DscResources | Where-Object Name -NotIn $skippedDscResources
        TestCaseCount        = @($testCases | Where-Object Skip -EQ $false).Count
    }
}

Describe 'DSC Composite Resources compile' -Tags FunctionalQuality {

    It "'<DscResourceName>' compiles" -TestCases $testCases {

        if ($Skip)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        $nodeData = @{
            NodeName                    = "localhost_$dscResourceName"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
        }
        $configurationData.AllNodes = @($nodeData)

        $dscConfiguration = @'
configuration TestConfig {

    #<importStatements>

    node 'localhost_<DscResourceName>_<ConfigPath>' {

        $data = $configurationData.Datum.Config.'<ConfigPath>'
        if (-not $data)
        {
            $data = @{}
        }

        (Get-DscSplattedResource -ResourceName <DscResourceName> -ExecutionName _<DscResourceName> -Properties $data -NoInvoke).Invoke($data)
    }
}
'@

        $dscConfiguration = $dscConfiguration.Replace('#<importStatements>', "Import-DscResource -ModuleName $DscModuleName -Name $DscResourceName")
        $dscConfiguration = $dscConfiguration.Replace('<DscResourceName>', $dscResourceName)
        $dscConfiguration = $dscConfiguration.Replace('<ConfigPath>', $configPath)

        $data = $configurationData.Datum.Config.$configPath
        Invoke-Expression -Command $dscConfiguration

        {
            TestConfig -ConfigurationData $configurationData -OutputPath $OutputDirectory -ErrorAction Stop
        } | Should -Not -Throw
    }

    It "'<DscResourceName>' should have created a mof file" -TestCases $testCases {

        if ($Skip)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        $mofFile = Get-Item -Path "$($OutputDirectory)\localhost_$($DscResourceName)_$($ConfigPath).mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }

}

Describe 'Final tests' -Tags FunctionalQuality {

    It 'Every DSC resource has compiled' -TestCases $finalTestCases {

        $mofFiles = Get-ChildItem -Path $OutputDirectory -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"
        $TestCaseCount | Should -Be $mofFiles.Count

    }

}
