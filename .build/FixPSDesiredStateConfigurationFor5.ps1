task FixPSDesiredStateConfigurationFor5 {

    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        $modulePath = "$RequiredModulesDirectory\PSDesiredStateConfiguration"
        if (Test-Path $modulePath)
        {
            Remove-Item -Path $modulePath -Recurse -Force
        }
    }
}
