@push
Feature: Apply DSC Configuration on remote Node
    While in Pull mode the MOF is generated before being made available on
    the Pull Server, in Push Mode we should either be able to Push a pre-compiled
    MOF document, or Push the Configuration script to the managed node to be compiled
    and applied. This Push mode should inject missing dependencies to the remote node,
    and allow to push those configuration to multiple nodes at once (in Parallel, 
    while setting a variable cap on the concurrency)
    
    @ManualSpec
    Scenario: Compile a MOF locally, inject dependencies, Start-DscConfiguration
        Given a DSC Configuration script compiling a MOF locally
        And we have a destination node available
        And the module is loaded
        When we call Push-DscModuleToNode
        And we copy the configuration MOF
        Then the DSC Configuration is applied successfully

    @Function
    Scenario: Compile a MOF locally and apply to remote node injecting dependencies
        Given a loaded DSC Configuration script
        And we have a destination node available
        And the module is loaded
        When we call Push-DscConfiguration -CompileMof Locally -Dependencies $Modules
        Then the DSC Configuration is applied successfully