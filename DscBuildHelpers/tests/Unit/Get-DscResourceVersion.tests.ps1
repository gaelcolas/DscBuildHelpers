$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here/../../*/$sut" #for files in Public\Private folders, called from the tests folder

Describe 'Get-DscResourceVersion' {

  Context 'General context'   {

    It 'runs without errors' {
        { Get-DscResourceVersion } | Should Not Throw
    }
    It 'does something' {
      
    }
    It 'does not return anything'     {
      Get-DscResourceVersion | Should BeNullOrEmpty 
    }
  }
}
