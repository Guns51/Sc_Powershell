[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$a= [System.Windows.Forms.MessageBox]::Show("Un utilisateur s'est connecte ($client_connect) avec le compte $user_connect",'Info ssh',1,48)
$a