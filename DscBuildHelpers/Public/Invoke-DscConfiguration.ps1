function Invoke-DscConfiguration {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $ConfigurationModuleName,

        [Parameter(
            Mandatory
        )]
        [string]
        $ConfigurationName,

        [Parameter(
            Mandatory
        )]
        [string]
        $DscBuildOutputConfigurations,

        [Parameter(
            Mandatory
        )]
        [hashtable]
        $ConfigurationData
    )

    if ( $pscmdlet.shouldprocess("Configuration module $ConfigurationModuleName and configuration $ConfigurationName") ) {
        Write-Verbose "Importing configuration module: $ConfigurationModuleName"
        if (Get-Module -list -name $ConfigurationModuleName) {

            $ResetVerbosePreference = $false
            if ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'].IsPresent) {
                $ResetVerbosePreference = $true
                $VerbosePreference = 'SilentlyContinue'
            }

            try  {
                import-module -name $ConfigurationModuleName -force -Verbose:$false -ErrorAction Stop
            }
            catch {
                Write-Warning "import-module -name '$ConfigurationModuleName' -force -Verbose:`$false -ErrorAction Stop # Command failed failed"
                Write-Warning "Failed to load configuration module: $ConfigurationModuleName"
                $Exception = $_.Exception
                do {
                    Write-Warning "`t$($_.Message)"
                    $Exception = $_.InnerException
                } while ($Exception -ne $null)
                throw "Failed to load $ConfigurationModuleName"
            }

            if ($ResetVerbosePreference) {
                $VerbosePreference = 'Continue'
            }
            Write-Verbose "Imported $ConfigurationModuleName"
            Write-Verbose ''
        }
        else {
            Write-Warning "Unable to resolve the module '$ConfigurationModuleName'"
            Write-Warning "Current modules on PSModulePath"
            $env:psmodulepath -split ';' |
                get-childitem -directory |
                    ForEach-Object {
                        Write-Warning "`tFound $($_.Name)"
                    }
            throw "Failed to load configuration module"
        }

        try
        {
            Write-Verbose ""
            Write-Verbose 'Starting to generate configurations.'
            Write-Verbose "`tWriting configurations to $DscBuildOutputConfigurations"
            $ErrorActionPreference = 'Stop'
            Write-Verbose "`tRunning $ConfigurationName"
            "Running:>_ $ConfigurationName -outputpath $DscBuildOutputConfigurations -ConfigurationData `$ConfigurationData -verbose" | Write-Verbose
                
            $null = .$ConfigurationName -outputpath $DscBuildOutputConfigurations -ConfigurationData $ConfigurationData -verbose    

            Write-Verbose "Done creating configurations. Get ready for some pullin' baby!"
            Write-Verbose ""
        }
        catch
        {
            Write-Warning 'Failed to generate configs.'
            throw 'Failed to generate configs.'
        }

        Remove-Module -Name $ConfigurationModuleName -Force
    }
}


