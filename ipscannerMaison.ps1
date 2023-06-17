
1..254 | % -Parallel {
    #$status = Test-Connection -TargetName 192.168.191.$_ -Count 1
    if (Test-Connection -TargetName 192.168.1.$_ -Count 1 -Quiet)
    {	
        $dnsName = (Resolve-DnsName 192.168.1.$_ -ErrorAction SilentlyContinue).NameHost
        if ($dnsName -eq $null)
        {
            $dnsName = "<notDnsName>"
        }
	    $resultTestSSH = Test-NetConnection -ComputerName 192.168.1.$_ -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($resultTestSSH)
        {
            $resultTestSSH = "OK:22"
        }
        Write-Host "Success > 192.168.1.$_ > $dnsName > $resultTestSSH"
    }
} -ThrottleLimit 150

