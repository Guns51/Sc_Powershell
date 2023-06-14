$BinaryMask = ""

$maskCDIR = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.PrefixLength
$chiffre0 = 32-$maskCDIR

for ($i = 0; $i -lt $maskCDIR; $i++) 
{
    $BinaryMask += "1"
}

for ($i = 0; $i -lt $chiffre0; $i++)
{
    $BinaryMask += "0"
}

$Octet1 = [Convert]::ToInt32($BinaryMask.Substring(0, 8), 2)
$Octet2 = [Convert]::ToInt32($BinaryMask.Substring(8, 8), 2)
$Octet3 = [Convert]::ToInt32($BinaryMask.Substring(16, 8), 2)
$Octet4 = [Convert]::ToInt32($BinaryMask.Substring(24, 8), 2)

$DecimalMask = "$Octet1.$Octet2.$Octet3.$Octet4"

$ipAddress = (Get-NetIPConfiguration | ? "NetProfile").IPv4Address.IPAddress
$ipAddressSplit = $ipAddress.Split('.')
$maskSplit = $DecimalMask.Split('.')

$NetworkAddress = @()

for ($i = 0; $i -lt 4; $i++) {
    $NetworkAddress += [byte]($ipAddressSplit[$i] -band $maskSplit[$i])
}
$NetworkAddress = $NetworkAddress -join "."
$NetworkAddress

$hotesAvecMasques = @{
    "30" = 2
    "29" = 6
    "28" = 14
    "27" = 30
    "26" = 62
    "25" = 126
    "24" = 254
    "23" = 510
    "22" = 1022
    "21" = 2046
    "20" = 4094
    "19" = 8190
    "18" = 16382
    "17" = 32766
    "16" = 65534
}

$firstIpAddress = $NetworkAddress

