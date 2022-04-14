function Clear-CachedDscResource {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param()

    if ($pscmdlet.ShouldProcess($env:computername)) {
        Write-Verbose 'Stopping any existing WMI processes to clear cached resources.'
        
        ### find the process that is hosting the DSC engine
        $dscProcessID = Get-WmiObject msft_providers |
          Where-Object {$_.provider -like 'dsccore'} |
            Select-Object -ExpandProperty HostProcessIdentifier 

        ### Stop the process
        if ($dscProcessID -and $pscmdlet.ShouldProcess('DSC Process')) {
            Get-Process -Id $dscProcessID | Stop-Process
        }
        else {
            Write-Verbose 'Skipping killing the DSC Process'
        }

        Write-Verbose 'Clearing out any tmp WMI classes from tested resources.'
        Get-DscResourceWmiClass -class tmp* | remove-DscResourceWmiClass
    }
}