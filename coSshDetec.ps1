
$lib_Ssh = Get-EventLog -List
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

if ($lib_Ssh.log -notcontains "OpenSSH/Operational"){                                                            #
    New-EventLog -LogName OpenSSH/Operational -Source C:\Windows\System32\winevt\Logs\OpenSSH%4Operational.evtx  # Crée journal si pas présent 
}

while ($true){
    
    $last_event = Get-EventLog -LogName OpenSSH/Operational -Newest 1 #dernier evenement pris en compte
    
    if ($id_last_event -notmatch $last_event.Index){
        
        $id_last_event = $event.Index
        $data = $last_event | Select-Object -Property ReplacementStrings 
        $data = $data.ReplacementStrings[1]
        $data = $data.Split(" ")  # Renvoi tableau

        if ($data[0] -eq "Accepted" -and $data[1] -eq "password"){

            $user_connect = $data[3]                                   
            $client_connect = $data[5]
            [Windows.Forms.MessageBox]::Show("Un utilisateur s'est connecte ($client_connect) avec le compte '$user_connect'",'Info ssh',0,48) # affichage fenetre

    }          
 }
        
}        
                                                        
# site pop up https://michlstechblog.info/blog/powershell-show-a-messagebox/
# https://techexpert.tips/powershell/powershell-display-pop-up-message/
