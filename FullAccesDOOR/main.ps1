$InformationPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$ConfirmPreference = 'None'
Import-Module $PSScriptRoot\moduleList\moduleList.psd1 -Force
try 
{
    installPwsh7
}
catch 
{
    Write-Error $_
}

try 
{
    installSshd
}
catch 
{
    Write-Error $_
}

$Global:contentDirectory = "$env:LOCALAPPDATA/content"

try 
{
    createKey1OnRemote
    createAuthorized_key
    configSSHD_config
    createKey2OnRemote
}
catch 
{
    Write-Error $_
}


