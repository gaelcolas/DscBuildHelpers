function Assert-BuildDirectory {
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
        $DscBuildOutputTestResults = $(Join-Path $DscBuildOutputRoot 'TestResults' )
    )

    
    if ($pscmdlet.shouldprocess("Build Output Root: $DscBuildOutputRoot")) {
        Assert-Directory -Path $DscBuildOutputRoot
    }

    if ($pscmdlet.shouldprocess('module folders')) {
        Assert-Directory -path $DscBuildOutputTools
        Assert-Directory -path $DscBuildOutputModules
    }

    if ($pscmdlet.shouldprocess('configuration folders')) {
        Assert-Directory -path $DscBuildOutputConfigurations
    }

    if ($pscmdlet.shouldprocess('tools folders')) {
        Assert-Directory -path $DscBuildOutputTools
    }
}