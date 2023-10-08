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
    createPrivateKeyOnRemote
    createAuthorized_key
    configSSHD_config
}
catch 
{
    Write-Error $_
}


if($null -ne (Get-PSSession)) #si une session est deja en cours
{
    Remove-PSSession -Name **
}
New-PSSession -HostName "20.199.12.168" -UserName "adm-Session" -Name "$env:USERNAME" -KeyFilePath "$Global:contentDirectory\id_rsa" -local