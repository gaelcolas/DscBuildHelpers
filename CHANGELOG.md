# Changelog for DscBuildHelpers

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Enabled all tests in 'Get-DscSplattedResource.Integration.Tests.ps1'.
- Improved module import handling and getting the module info from 'Get-Module' if
  already imported.
- Updated build scripts to Sampler 0.119.0-preview0005 for fixing issues with debugging.
- Improved 'SupportsShouldProcess' handling in 'Clear-CachedDscResource.ps1'.
- Added 'SupportsShouldProcess' to 'Remove-DscResourceWmiClass'.
- 

### Added

- Added support for complex data types in MOF-based and class-based resources by
  rewriting 'Get-DscSplattedResource' and adding these functions:
  - 'Get-CimType'.
  - 'Get-DynamicTypeObject'.
  - 'Get-PropertiesData'.
  - 'Write-CimProperty'.
  - 'Write-CimPropertyValue'.
  - 'Get-DscResourceProperty'.
  - 'Initialize-DscResourceMetaInfo'.
- Add integration tests for Get-DscResourceProperty function.
  - Add latest versions of' NetworkingDsc', 'ComputermanagementDsc', and 'Microsoft365DSC'
    to 'RequiredModules.psd1' for 'Get-DscResourceProperty' integration tests.
- Added integration test for 'Initialize-DscResourceMetaInfo' and added 'SharePointDsc'.

### Fixed

- Fixed null reference check for array type in 'Get-DscResourceProperty' function.
  An error was thrown that the property 'IsArray' could not be found.
- Fixed a bug in 'Initialize-DscResourceMetaInfo' when importing for example
  'SharePointDsc', which returns 2 objects.

## [0.2.3] - 2024-11-09

### Changed

- Moved the DSC resource modules from `output\RequiredModules` to `\tests\Integration\Assets\DscResources\` and
  updated the discovery in Get-DscSplattedResource.Integration.Tests.ps1.

### Changed

- Updated build scripts.
- Made build compatible with PowerShell 5 and 7.
- Aligned dependencies with other related projects.
- Aligned 'build.yml' with one from other related projects.
- Aligned 'azure-pipelines' with one from other related projects.
  - Build runs on PowerShell 5 and 7 now.
- Set gitversion in Azure pipeline to 5.*.
- Made code HQRM compliant and added HQRM tests.
- Added Pester tests for 'Get-DscSplattedResource'.
- Fixed a bug in 'Get-DscResourceProperty'
- Added integration tests for 'Get-DscSplattedResource'.
- Added datum test data for 'Get-DscSplattedResource'.
- Added code coverage and code coverage merge.

## [0.2.2] - 2024-04-03

### Added

- Added support for CIM based properties.

### Changed

- Migration of build pipeline to Sampler.

### Fixed

- Initialize-DscResourceMetaInfo:
  - Fixed TypeConstraint, 'MSFT_KeyValuePair' should be ignored.
  - Fixed non-working caching test.
  - Added PassThru pattern for easier debugging.
  - Considering CIM instances names 'DSC_*' in addition to MSFT_*.
- Get-DscResourceFromModuleInFolder:
  - Redesigned the function. It did not work with PowerShell 7 and
    PSDesiredStateConfiguration 2.0.7.
- Changed the remaining lines in alignment to PR #14.

## [0.2.1] - 2022-04-16

### Changed

First release done with Sampler.
