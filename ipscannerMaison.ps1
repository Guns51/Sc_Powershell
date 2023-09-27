#Necessite pswh 7 >>>
if(!(Test-Path -Path "C:\progra~1\powershell\7\pwsh.exe"))
{
    winget install --id Microsoft.Powershell --source winget
    Start-Job -Name "installPwsh7" -ScriptBlock { winget install --id Microsoft.Powershell --source winget } -InformationAction SilentlyContinue
    Wait-Job -Name "installPwsh7" -InformationAction SilentlyContinue
    Remove-Job -Name "installPwsh7"
} 

pwsh -Command {
#maskCDIR,ipAddress,byteHote
$maskCDIR = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.PrefixLength
#$maskCDIR = 20 #pour test
$ipAddress = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.IPAddress
#$ipAddress = "172.18.203.15" #pour test
$byteHote = 32-$maskCDIR

function convertMaskCdirToBin #Convertion du CDIR en binaire
{
    $BinaryMask = ""
    #Création du mask en binaire grave au CDIR
    for ($i = 0; $i -lt $maskCDIR; $i++) 
    {
        $BinaryMask += "1"
    }

    for ($i = 0; $i -lt $byteHote; $i++)
    {
        $BinaryMask += "0"
    }
    return $BinaryMask
}
function convertMaskBinToDecimal #retourne le masque en decimal sous forme XXX.XXX.XXX.XXX à partir du binaire
{
    $BinaryMask = convertMaskCdirToBin
    $Octet1 = [Convert]::ToInt32($BinaryMask.Substring(0, 8), 2)
    $Octet2 = [Convert]::ToInt32($BinaryMask.Substring(8, 8), 2)
    $Octet3 = [Convert]::ToInt32($BinaryMask.Substring(16, 8), 2)
    $Octet4 = [Convert]::ToInt32($BinaryMask.Substring(24, 8), 2)

    $DecimalMask = "$Octet1.$Octet2.$Octet3.$Octet4"
    return $DecimalMask
}
function calculNetAddress #retourne addresse ip du réseau
{
    $ipAddressSplit = $ipAddress.Split('.')
    $maskSplit = (convertMaskBinToDecimal).Split('.')

    $NetworkAddress = @()

    #Operation et logique pour trouver adresse réseau
    for ($i = 0; $i -lt 4; $i++) {
        $NetworkAddress += [byte]($ipAddressSplit[$i] -band $maskSplit[$i])
    }
    $NetworkAddress = $NetworkAddress -join "."
    Return $NetworkAddress
}
function calculNombreHotes #retourne le nombre d'hote en decimal
{
    $nombreHotes = [Math]::Pow(2,$byteHote)-2
    return $nombreHotes
}
function convertNetworkAddressIpToBinary #sous forme XXX.XXX.XXX.XXX
{
    $adressesplit = (calculNetAddress).Split(".")
    $ipBIN = @()
    $adressesplit | ForEach-Object{
        $bindepart = [System.Convert]::ToString($_,2)
        $binfin=""
        $bin = 8 - $bindepart.Length
        for($i=0;$i -lt $bin; $i++){$binfin += "0"}
        $ipBIN += $binfin + $bindepart
    }
    $ipBIN = $ipBIN -join ""
    return $ipBIN
}

Function calculIpToPing
{
    $ipDecimal = [Convert]::ToInt64((convertNetworkAddressIpToBinary), 2)
    1..(calculNombreHotes) | ForEach-Object{
        $ip = $ipDecimal+$_
        $ip = [Convert]::ToString($ip, 2)
        $Octet1 = [Convert]::ToInt64($ip.Substring(0, 8), 2)
        $Octet2 = [Convert]::ToInt64($ip.Substring(8, 8), 2)
        $Octet3 = [Convert]::ToInt64($ip.Substring(16, 8), 2)
        $Octet4 = [Convert]::ToInt64($ip.Substring(24, 8), 2)
        $ipToPing = "$Octet1.$Octet2.$Octet3.$Octet4"
        return $ipToPing
    }
}

$ips = calculIpToPing
$ips | % -Parallel {

    if (Test-Connection -TargetName $_ -Count 1 -Quiet)
    {	
        #####################################Get-DnsName##############################################
        $dnsName = (Resolve-DnsName $_ -ErrorAction SilentlyContinue).NameHost
        if ($dnsName -eq $null)
        {
            $dnsName = "<notDnsName>"
        }
        #####################################Get-AddressMac##############################################
        $ipAddress = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.IPAddress
        if ($_ -ne $ipAddress)
        {
            $addressMac = (Get-NetNeighbor -IPAddress $_ -InformationAction SilentlyContinue).LinkLayerAddress
            if ($addressMac -eq "00-00-00-00-00-00")
            {
                $addressMac = "<notMacAdd>"
            }
        }else 
        {
            $addressMac =  (Get-NetIPConfiguration | ? "NetProfile").NetAdapter.MacAddress
        }
        ######################################Get-CoSSH##################################################
	    $resultTestSSH = Test-NetConnection -ComputerName $_ -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($resultTestSSH)
        {
            $resultTestSSH = "OK:22"
        }
        else {$resultTestSSH = "NULL:22"}
        ######################################Get-CoHTTP##################################################
        $resultTestHttp = Test-NetConnection -ComputerName $_ -Port 80 -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($resultTestHttp)
        {
            $resultTestHttp = "OK:80"
        }
        else {$resultTestHttp = "NULL:80"}
        ####################################################################################################

        Write-Host "Success > $_ > $dnsName > $addressMac > $resultTestSSH > $resultTestHttp"

    }
} -ThrottleLimit 150
}
