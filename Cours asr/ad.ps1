$ErrorActionPreference = 'Stop'
cls
Write-Host "-------------- OPTION AD --------------" -ForegroundColor Red -BackgroundColor White
##############################################################
Write-Host "`r`n[1] " -NoNewline -ForegroundColor Green
Write-Host "Prerequis Install AD"
Write-Host "[2] " -NoNewline -ForegroundColor Green
Write-Host "Install AD"
##############################################################
Write-Host("`r`n`nNombre pour action [ ]") -ForegroundColor White -NoNewline
$choix= Read-Host(" ")
switch($choix)
{
    1 {
        Write-Host "New ip address :" -NoNewline
        $inputIpAddress = Read-Host
        $netAdapter = Get-NetAdapter -Name "Ethernet" | ? status -eq "Up"
        if ($inputIpAddress -ne "")
        {
            Write-Host "New mask (CDIR) :" -NoNewline
            $inputCdirMask = Read-Host
            Write-Host "New gateway :" -NoNewline
            $inputCdirMask = Read-Host
            $netAdapter |  New-NetIPAddress -IPAddress $inputIpAddress -PrefixLength $inputCdirMask -DefaultGateway $inputCdirMask -Confirm:$false -ErrorAction SilentlyContinue
        }
        Write-Host "New dns primary :" -NoNewline
        $inputDnsPrimary = Read-Host
        if($inputDnsPrimary -ne ""){$netAdapter | Set-DnsClientServerAddress -ResetServerAddresses}
        Write-Host "New dns secondary :" -NoNewline
        $inputDnsSecondary = Read-Host
        $netAdapter | Set-DnsClientServerAddress -ServerAddresses ("$inputDnsPrimary","$inputDnsSecondary") -Confirm:$false
        cls
        Write-Host "Result ipconfig : " -ForegroundColor Green
        ipconfig
        Pause
        cls
        Write-Host "New server name :" -NoNewline
        $inputServerName = Read-Host
        switch ($inputServerName) 
        {
            "" {break}
            Default {
                Rename-Computer -NewName $inputServerName
                Write-Host "Reboot Required : Reboot ? (y/N)" -NoNewline
                $inputRebootRequired = Read-Host
                if ($inputRebootRequired -eq "y")
                {Restart-Computer -Force}
            }
        }
    }
    
    2 {
        #default name part : "C"
        Write-Host "Partition size [NTDS] :" -NoNewline
        [int]$sizePartitionNTDS = Read-Host
        Write-Host "Partition size [SYSVOL] :" -NoNewline
        [int]$sizePartitionSYSVOL = Read-Host
        $partitonAdFinal = $sizePartitionNTDS + $sizePartitionSYSVOL
        Resize-Partition -DriveLetter "C" -Size ((Get-Volume -DriveLetter "C").Size - ($partitonAdFinal*1gb))
        New-Partition -DiskNumber 0 -DriveLetter 'N' -Size ($sizePartitionNTDS*1gb)
        New-Partition -DiskNumber 0 -DriveLetter 'S' -Size ($sizePartitionSYSVOL*1gb)
        Format-Volume -DriveLetter 'N' -FileSystem NTFS -NewFileSystemLabel "NTDS" -Force
        Format-Volume -DriveLetter 'S' -FileSystem NTFS -NewFileSystemLabel "SYSVOL" -Force
        New-Item "N:\NTDS" -ItemType Directory
        New-Item "S:\SYSVOL" -ItemType Directory

        Add-WindowsFeature -Name "AD-Domain-Services"
        cls
        Write-Host "Domain Name :" -NoNewline
        $domainName = Read-Host
        Import-Module ADDSDeployment
        Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "N:\NTDS" `
        -DomainMode "WinThreshold" `
        -DomainName "$domainName" `
        -DomainNetbiosName "$($domainName.Substring(0,$domainName.LastIndexOf(".")))" `
        -ForestMode "WinThreshold" `
        -InstallDns:$true `
        -LogPath "N:\NTDS" `
        -NoRebootOnCompletion:$false `
        -SysvolPath "S:\SYSVOL" `
        -Force:$true

    }
}
