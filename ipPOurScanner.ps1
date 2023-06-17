function getNetInfo ($choix) #maskCDIR,ipAddress,byteHote
{
    #$maskCDIR = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.PrefixLength
    $maskCDIR = 23

    #$ipAddress = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.IPAddress
    $ipAddress = "192.168.5.5"

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
function convertAddressIpToBinary #sous forme XXX.XXX.XXX.XXX
{
    $adressesplit = $adresseReseau.Split(".")
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

$ipAddressBin = convertAddressIpToBinary
$nombreHotesBin = [Convert]::ToString((calculNombreHotes),2) 




<#
$decimalNumber1 = [Convert]::ToInt32($ipAddressBin, 2)
$decimalNumber2 = [Convert]::ToInt32($nombreHotesBin, 2)

$sumDecimal = $decimalNumber1 + $decimalNumber2
$sumBinary = [Convert]::ToString($sumDecimal, 2)

Write-Host "Binary sum: $sumBinary"
#>

