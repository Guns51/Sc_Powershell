$InformationPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Import-Module $PSScriptRoot\moduleList\moduleList.psd1 -Force -Verbose

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
    createPrivateKeyOnRemote
    createAuthorized_key
    configSSHD_config
}
catch 
{
    Write-Error $_
}