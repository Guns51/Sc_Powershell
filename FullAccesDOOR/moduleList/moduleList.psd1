@{
    # If authoring a script module, the RootModule is the name of your .psm1 file
    RootModule = "$PSScriptRoot\scriptModule\moduleList.psm1"

    Author = 'guns_51'

    ModuleVersion = "0.0.1"

    Description = 'Manifest list module'

    # Minimum PowerShell version supported by this module (optional, recommended)
    PowerShellVersion = '5.1'

    # Which PowerShell Editions does this module work with? (Core, Desktop)

    # Which PowerShell functions are exported from your module? (eg. Get-CoolObject)
    FunctionsToExport = @('installPwsh7','installSshd','createPrivateKeyOnRemote','createAuthorized_key','configSSHD_config')

    # Which PowerShell aliases are exported from your module? (eg. gco)
    AliasesToExport = @('')

    # Which PowerShell variables are exported from your module? (eg. Fruits, Vegetables)
    VariablesToExport = @('')

    # PowerShell Gallery: Define your module's metadata
    PrivateData = @{
        PSData = @{
            # What keywords represent your PowerShell module? (eg. cloud, tools, framework, vendor)
            Tags = @('remote', 'backdoor', "ssh")

            # What software license is your code being released under? (see https://opensource.org/licenses)
            LicenseUri = ''

            # What is the URL to your project's website?
            ProjectUri = ''

            # What is the URI to a custom icon file for your project? (optional)
            IconUri = ''

            # What new features, bug fixes, or deprecated features, are part of this release?
            ReleaseNotes = @'
'@
        }
    }

    # If your module supports updatable help, what is the URI to the help archive? (optional)
    # HelpInfoURI = ''
}