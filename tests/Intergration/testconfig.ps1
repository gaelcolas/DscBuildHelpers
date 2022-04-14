Configuration MyDscBuildHelperTest {
    $props = @{
        Ensure = 'Present'
        Type = 'File'
        Contents = 'blah'
        DestinationPath = 'C:\test.txt'
    }

    (Get-DscSplattedResource -ResourceName File -ExecutionName MyFile -Properties $props -NoInvoke).invoke($props)

}

MyDscBuildHelperTest