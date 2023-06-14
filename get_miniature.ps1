Function Miniature 
{
    $VIDEO_ID = (Read-Host("Url De La Video")).Substring(32)
    $videoUrl = "https://i.ytimg.com/vi/$VIDEO_ID"

    try 
    {
        $thumbnailUrl = $videoUrl + "/maxresdefault.jpg"
        $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
    }
    catch 
    {
        try 
        {
            $thumbnailUrl = $videoUrl + "/sddefault.jpg"
            $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
        }
        catch 
        {
            try 
            {
                $thumbnailUrl = $videoUrl + "/hqdefault.jpg"
                $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
            }
            catch 
            {
                try 
                {
                    $thumbnailUrl = $videoUrl + "/mqdefault.jpg"
                    $response = Invoke-WebRequest -Uri $thumbnailUrl -UseBasicParsing -ErrorAction Stop
                }
                catch 
                {
                    Write-Output ("$_")
                }
            }
        }
    }

    $jours = Get-Date -UFormat "%d-%m"
    $heure = Get-Date -UFormat "%HH%M-%Ss"
    $thumbnailPath = "$env:USERPROFILE\Desktop\Images\$jours\$heure.jpg"
    New-Item -Path $thumbnailPath -ItemType File -Force -InformationAction SilentlyContinue
    $response.Content | Set-Content $thumbnailPath -Encoding Byte -Force
}
Miniature