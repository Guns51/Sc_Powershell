

<#
while ($true){
    $a = Test-Connection 8.8.8.8 -Count 1 | Select-Object -Property Status
    Start-Sleep 1
    if ($a -match "Success"){
        Write-Output('oue')
    }
} 
#>

function test {
    param (
        $b
    )
    if ($b -match "Success"){
        Write-Host('ok')
    else {
        Write-Host('pasok')
    }
    }
}
test((Test-Connection 8.8.8.8 -Count 1 | Select-Object -Property Status))

