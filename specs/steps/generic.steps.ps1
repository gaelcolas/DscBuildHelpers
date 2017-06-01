
Given 'we have xCertificate module in the ./module/ folder' {
    $RelativePathToDemo = "$PSScriptRoot/../../*/Examples/demo2/"
    Get-Module -ListAvailable "$RelativePathToDemo/modules/xCertificate" -errorAction SilentlyContinue  | should not BeNullOrEmpty
}

Given 'we have a destination node available' {
    
    if ( -not ($computername = $Env:TargetNode )) { $computername = 'localhost' }
    if ( -not ($global:creds)) { $global:creds = Get-Credential }
    $RemoteNode = New-PSsession -computerName $computername -Credential $global:creds -ErrorAction Stop
    $script:RemoteSession = $RemoteNode
    { Invoke-command -Session $script:RemoteSession -ScriptBlock { 'checked' } -ErrorAction Stop } | Should not Throw
}

Given 'The module is loaded' {
    $ModulePath = "$PSScriptRoot/../../*/DscBuildHelpers.psd1"
    Test-Path $ModulePath | Should Be $true
    Import-module $ModulePath -Force
    Get-Module DscBuildHelpers | should not BeNullOrEmpty
}