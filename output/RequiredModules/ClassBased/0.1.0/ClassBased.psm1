enum Ensure
{
    Absent
    Present
    Unknown
}

[DscResource()]
class ClassBasedResource1
{
    [DscProperty(Key = $true)]
    [string]$Key1

    [DscProperty(Key = $true)]
    [string]$Key2

    [DscProperty(Mandatory = $true)]
    [string]$String1

    [DscProperty()]
    [string]$String2

    [DscProperty(Mandatory = $true)]
    [string[]]$Strings1

    [DscProperty(Mandatory = $true)]
    [bool]$Bool1

    [DscProperty()]
    [Ensure]
    $Ensure

    ClassBasedResource1()
    {
        $this.Ensure = 'Present'
    }

    [bool]Test()
    {
        return $true
    }

    [ClassBasedResource1]Get()
    {
        $currentState = [ClassBasedResource1]::new()

        return $currentState
    }

    [void]Set()
    {
    }
}

[DscResource()]
class ClassBasedResource2
{
    [DscProperty(Key = $true)]
    [string]$Key

    [DscProperty()]
    [CustomObject1]$Object1

    [DscProperty()]
    [CustomObject1[]]$Object1Group

    [DscProperty()]
    [Ensure]
    $Ensure

    ClassBasedResource2()
    {
        $this.Ensure = 'Present'
    }

    [bool]Test()
    {
        return $true
    }

    [ClassBasedResource2]Get()
    {
        $currentState = [ClassBasedResource2]::new()

        return $currentState
    }

    [void]Set()
    {
    }
}

[DscResource()]
class ClassBasedResource3
{
    [DscProperty(Key = $true)]
    [string]$Key

    [DscProperty()]
    [CustomObject1[]]$Object1Group

    [DscProperty()]
    [CustomObject1]$Object1

    [DscProperty()]
    [CustomObject2]$Object2

    [DscProperty()]
    [Ensure]$Ensure

    ClassBasedResource3()
    {
        $this.Ensure = 'Present'
    }

    [bool]Test()
    {
        return $true
    }

    [ClassBasedResource3]Get()
    {
        $currentState = [ClassBasedResource3]::new()

        return $currentState
    }

    [void]Set()
    {
    }
}

class CustomObject1
{
    [DscProperty()]
    [string]$String1

    [DscProperty()]
    [bool]$Bool1

    CustomObject1()
    {
    }
}

class CustomObject1Group
{
    [DscProperty()]
    [CustomObject1[]]$CustomObjects

    CustomObject1Group()
    {
    }
}


class CustomObject2
{
    [DscProperty()]
    [string]$String1

    [DscProperty()]
    [CustomObject21]$Object1

    [DscProperty()]
    [CustomObject21[]]$Object1Group

    [DscProperty()]
    [CustomObject22]$Object2

    CustomObject2()
    {
    }
}

class CustomObject21
{
    [DscProperty()]
    [string]$String1

    [DscProperty()]
    [bool]$Bool1

    CustomObject21()
    {
    }
}

class CustomObject22
{
    [DscProperty()]
    [string]$String1

    [DscProperty()]
    [bool]$Bool1

    CustomObject22()
    {
    }
}
