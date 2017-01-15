function Assert-DestinationDirectory {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputRoot = 'C:\BuildOutput',
        
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputModules = $(Join-Path $DscBuildOutputRoot 'Modules' ),
        
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputTools = $(Join-Path $DscBuildOutputRoot 'Tools' ),
        
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputConfigurations = $(Join-Path $DscBuildOutputRoot 'Configurations' ),
        
        [ValidateNotNullOrEmpty()]
        $DscBuildOutputTestResults = $(Join-Path $DscBuildOutputRoot 'TestResults' ),

        [switch]
        $BuildConfigurations,

        [switch]
        $BuildResources,

        [switch]
        $BuildTools
    )

    foreach ($keyToDelete in @('WhatIf','ConfirmImpact') ) {
        if ( $PSBoundParameters.containskey($keyToDelete) ) {
           $null = $PSBoundParameters.remove($keyToDelete)
        }
    }

    if ($pscmdlet.shouldprocess("Build Output Root: $DscBuildOutputRoot")) {
        Assert-Directory -Path $DscBuildOutputRoot
    }

    if ( $BuildResources ) {
        if ($pscmdlet.shouldprocess('module folders')) {
            Assert-Directory -path $DscBuildOutputTools @psboundparameters
            Assert-Directory -path $DscBuildOutputModules @psboundparameters
        }
    }

    if ( $BuildConfigurations ) {
        if ($pscmdlet.shouldprocess('configuration folders')) {
            Assert-Directory -path $DscBuildOutputConfigurations @PSBoundParameters
        }
    }

    if ( $BuildTools ) {
        if ($pscmdlet.shouldprocess('tools folders')) {
            Assert-Directory -path $DscBuildOutputTools @PSBoundParameters
        }
    }
}