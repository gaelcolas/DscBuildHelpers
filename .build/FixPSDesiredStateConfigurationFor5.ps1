task FixPSDesiredStateConfigurationFor5 {

    Write-Build Magenta "---------ComputerName: $($env:COMPUTERNAME)"
    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        $modulePath = "$RequiredModulesDirectory\PSDesiredStateConfiguration"
        if (Test-Path $modulePath)
        {
            Remove-Item -Path $modulePath -Recurse -Force
        }
    }
}
