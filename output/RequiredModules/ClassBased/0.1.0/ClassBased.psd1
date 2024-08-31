@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'ClassBased.psm1'

    # Version number of this module.
    ModuleVersion        = '0.1.0'

    # ID used to uniquely identify this module
    GUID                 = '2f2944bf-3a48-4a14-bb6d-62a511e434a3'

    # Author of this module
    Author               = 'DscCommunity'

    # Company or vendor of this module
    CompanyName          = 'DscCommunity'

    # Copyright statement for this module
    Copyright            = '(c) DscCommunity. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC Module for managing the ADSync configuration'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # DSC resources to export from this module
    DscResourcesToExport = @('ClassBasedResource1', 'ClassBasedResource2', 'ClassBasedResource3')

}
