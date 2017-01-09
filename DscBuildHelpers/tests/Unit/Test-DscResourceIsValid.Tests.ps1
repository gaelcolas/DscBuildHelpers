$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".ps1")
$pathToFileFromUnitTest = '../../*/'
$pathtosut = [System.Io.Path]::Combine($here, $pathToFileFromUnitTest, $sut)

. $pathtosut

Describe 'how Assert-DscModuleResourceIsValid behaves' {

    context 'when there are failed DSC resources' {
        mock Get-DscResourceForModule -mockwith {}
        mock Get-FailedDscResource -mockwith {
            [pscustomobject]@{name='TestResource'},
            [pscustomobject]@{name='SecondResource'}
        }

        it 'should throw an exception' {
            { Assert-DscModuleResourceIsValid} |
                should throw
        }
    }

    context 'when there are no DSC resources' {
        mock Get-DscResourceForModule -mockwith {}
        mock Get-FailedDscResource -mockwith {}

        it 'should not throw an exception' {
            { Assert-DscModuleResourceIsValid } | Should Not Throw
        }
    }

    context 'when all DSC resources are valid' {
        mock Get-DscResourceForModule -mockwith {
            [pscustomobject]@{name='TestResource'},
            [pscustomobject]@{name='SecondResource'}
        }
        mock Get-FailedDscResource -mockwith {}

        it 'should not throw an exception' {
            { Assert-DscModuleResourceIsValid } | Should Not Throw
        }
    }
}