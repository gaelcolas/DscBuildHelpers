=== Changelog

- Adding BuildHelpers as dependency
- Support for Multiple versions in Test-DscResourceIsValid
- Added example resources xStorage with 2 versions
- Making more functions public to use without Invoke-DscBuild
- Updated Clear-CachedDscResource to only kill the dsccore process
- Transformed Functions to not rely on Script scope variable but parameters (may change again) 
- removed DSCChecksum to use the provided command New-DSCChecksum
- Offloaded logic to Publish-ConfigurationToPullServer, Publish-MOFToPullServer from xPSDesiredStateConfiguration 

