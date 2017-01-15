$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here/../../*/$sut" #for files in Public\Private folders, called from the tests folder

Describe 'Import-DataFile' {

  Context 'General context'   {

  Mock Get-Content -MockWith {"@{'a'='b'}"}

    It 'runs without errors' {
        { Import-DataFile -Path TestDrive:\Test.psd1 } | Should Not Throw
    }

    It 'return expected data'     {
      $result = Import-DataFile -Path TestDrive:\Test.psd1
      $result | Should not BeNullOrEmpty
      $result.a | Should be 'b'
    }

  }
}
