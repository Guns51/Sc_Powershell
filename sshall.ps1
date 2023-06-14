while ($true){

    $status_install = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
    $status_install = $status_install.State

    if ($status_install -match "NotPresent"){
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
        Start-Service -Name sshd
        Set-Service -Name sshd -StartupType Automatic
    }    
    

    if ($status_install -match "Installed"){

        $status_lanch = Get-Service -Name sshd 
        $status_lanch = $status_lanch.Status

            if ($status_lanch -notmatch "Running"){
                Start-Service -Name sshd
                Write-Host("Service Demarré")
            }
    }

    Start-Sleep -Seconds 5

}