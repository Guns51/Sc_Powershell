while(1)
{
    if(Get-Process -Name LeagueClientUx -ErrorAction SilentlyContinue)
    {
        Start-Process "C:\Users\gunsa\Desktop\Sc_Powershell\appLOL\trueMain.exe"
        sleep 5
        while(get-process -Name "trueMain")
        {
            sleep 7
        }
    }
}