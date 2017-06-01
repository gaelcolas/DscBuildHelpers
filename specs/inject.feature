@inject
Feature: Allow injecting Modules and resources to remote host
    To allow applying configureation MOFs, the managed node needs
    to have the required Resources and modules installed locally.
    In Pull mode, the LCM grabs and install them from the Pull Server,
    while in Push mode we need to Inject them.

    @ManualSpec
    Scenario: transfer local xCertificate module to remote nodes 'manually'
        Given we have xCertificate module in the ./module/ folder
        And we have a destination node available
        And The module is loaded
        When we package-up each module
        And we transfer those modules to remote node
        And we extract to destination module path
        And we call get-module -Listavailable
        Then the copied modules are present and available
    

    @functions
    Scenario: Call Push-DscDependenciesToNode to inject dependencies
        Given we have xCertificate module in the ./module/ folder
        And we have a destination node available
        And The module is loaded
        When we call Push-DscModuleToNode
        And we call get-module -Listavailable
        Then the copied modules are present and available
