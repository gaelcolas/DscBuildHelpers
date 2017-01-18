Configuration SimpleConfig {
    Import-DSCResource -ModuleName @{ModuleName='xStorage';ModuleVersion='2.9.0.0'}
    
    Node $AllNodes.NodeName {
        xWaitforDisk Disk1
        {
             DiskNumber = 1
             RetryIntervalSec = 60
             RetryCount = 60
        }
    }
}