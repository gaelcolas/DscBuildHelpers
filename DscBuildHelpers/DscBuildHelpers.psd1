@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'DscBuildHelpers.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.1'

    # ID used to uniquely identify this module
    GUID              = '23ccd4bf-0a52-4077-986f-c153893e5a6a'

    # Author of this module
    Author            = 'Gael Colas'

    # Company or vendor of this module
    #CompanyName = 'SynEdgy Limited'

    # Copyright statement for this module
    Copyright         = '(c) 2017 Gael Colas. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Build Helpers for DSC Resources and Configurations'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{ ModuleName = 'xDscResourceDesigner'; ModuleVersion = '1.9.0.0'} #tested with 1.9.0.0
)

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @('.\ScriptsToProcess\Get-DscSplattedResource.ps1')

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    #CmdletsToExport = '*'

    # Variables to export from this module
    #VariablesToExport = '*'

    # Aliases to export from this module
    # AliasesToExport = 'Resolve-ConfigurationProperty'

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    # PrivateData = ''

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}