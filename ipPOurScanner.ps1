function getNetInfo ($choix) #maskCDIR,ipAddress,byteHote
{
    #$maskCDIR = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.PrefixLength
    $maskCDIR = 20

    #$ipAddress = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.IPAddress
    $ipAddress = "192.168.40.250"

    $byteHote = 32-$maskCDIR

    switch ($choix) 
    {
        "maskCDIR" { return $maskCDIR }
        "ipAddress" { return $ipAddress }
        "byteHote" { return $byteHote }
    }
}
function convertMaskCdirToBin #Convertion du CDIR en binaire
{
    $maskCDIR = getNetInfo "maskCDIR"
    $BinaryMask = ""
    #Création du mask en binaire grave au CDIR
    for ($i = 0; $i -lt $maskCDIR; $i++) 
    {
        $BinaryMask += "1"
    }

    $byteHote = getNetInfo "byteHote"
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
    $ipAddressSplit = (getNetInfo "ipAddress").Split('.')
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
    $byteHote = getNetInfo "byteHote"
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

function calculPartHote # retourne la partie hote pour la calcul de lip de debut et fin
{
    $NetworkAddressBin = convertNetworkAddressIpToBinary

    $Octet1 = $NetworkAddressBin.Substring(0, 8)
    $Octet2 = $NetworkAddressBin.Substring(8, 8)
    $Octet3 = $NetworkAddressBin.Substring(16, 8)
    $Octet4 = $NetworkAddressBin.Substring(24, 8)

    $byteHoteLength = getNetInfo "byteHote"
    
    if (($byteHoteLength)%8 -ne 0)
    {
        $reste = ($byteHoteLength)%8
        $byteHote = 8-$reste
        $byteHoteLength = $byteHoteLength+$byteHote
    }

    switch ($byteHoteLength) 
    {
        8 {return $Octet4}
        16 { return $Octet3+$Octet4}
        24 { return $Octet2+$Octet3+$Octet4}
    }
}


$decimalNumber1 = [Convert]::ToInt64((convertNetworkAddressIpToBinary), 2)
$decimalNumber2 = calculNombreHotes

$lastPartHoteDecimal = $decimalNumber1 + $decimalNumber2
$lastPartHoteBin = [Convert]::ToString($lastPartHoteDecimal, 2) #derniere ip partie hote en binaire

$Octet1 = [Convert]::ToInt64($lastPartHoteBin.Substring(0, 8), 2)
$Octet2 = [Convert]::ToInt64($lastPartHoteBin.Substring(8, 8), 2)
$Octet3 = [Convert]::ToInt64($lastPartHoteBin.Substring(16, 8), 2)
$Octet4 = [Convert]::ToInt64($lastPartHoteBin.Substring(24, 8), 2)

Write-Host "derniere ip: $Octet1.$Octet2.$Octet3.$Octet4"

$NetworkAddress = calculNetAddress
Write-Host "ADD Network: $NetworkAddress"