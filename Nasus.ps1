New-Item -ItemType File -Path ($env:USERPROFILE + "\test\oueoue.ps1") -Value $block -Force

function task
{
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-ExecutionPolicy bypass -File "+ $env:USERPROFILE + "\test\oueoue.ps1")
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -ExecutionTimeLimit (New-TimeSpan -Days 90)
    $task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $settings
    Register-ScheduledTask "cc" -InputObject $task -Force
    Start-ScheduledTask -TaskName "cc"
}
task    

##########
ssh -i ".\ec2Vir.pem" admin@13.39.106.145 -t @(sudo mysql << test
USE Historique
INSERT INTO trucBizarre (id, heure, site) VALUES (NULL, 'testHeure', 'testSite');
test)

sudo mysql << test > test
USE Historique
Select * from trucBizarre;
test
#######


$donnee = "sudo mysql << EOF
USE Historique
INSERT INTO trucBizarre (id, heure, site) 
VALUES "


$oldCache = Get-DnsClientCache -Type A | Select-Object -Unique -Property Entry, TimeToLive
#Start-Sleep -Seconds 10
$newCache = Get-DnsClientCache -Type A | Select-Object -Unique -Property Entry, TimeToLive
$newSiteDns = Compare-Object -ReferenceObject $oldCache -DifferenceObject $newCache -Property Entry
$date = Get-Date -UFormat "%d/%m/%Y %R"
$newSiteDns.Entry |
ForEach-Object -Begin $null -Process {$donnee += "(NULL, '$date', '$_'),"} -End {$donnee = $donnee.Remove($donnee.Length-1) +";"}
$donnee


ssh -i ".\ec2Vir.pem" admin@13.39.106.145 -t ($donnee)
