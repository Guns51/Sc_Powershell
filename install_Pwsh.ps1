if(!(Test-Path -Path "C:\progra~1\powershell\7\pwsh.exe"))
{
    Start-Job -Name "installPwsh7" -ScriptBlock { winget install --id Microsoft.Powershell --source winget } -InformationAction SilentlyContinue
    Wait-Job -Name "installPwsh7" -InformationAction SilentlyContinue
    Remove-Job -Name "installPwsh7"
} 