[Si Vrai]

if ( ((Get-NetFirewallRule -DisplayName ping2).enabled) -eq "true") {
Write-Host "bonjour"
}else{
Write-Host "pas bonjour"}

[Si Faux]

if ( ((Get-NetFirewallRule -DisplayName ping2).enabled) -eq "false") {
Write-Host "bonjour"
}else{
Write-Host "pas bonjour"}

