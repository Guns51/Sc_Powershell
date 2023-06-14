$nomMusiqueArtiste = (Read-Host("nom musique nom artiste")).Split(" ")
$musique = $nomMusiqueArtiste[0]
$artiste = $nomMusiqueArtiste[1]

function request_token()
{
    $client_id = '10d30621aa8745b986b498752f608d2f'
    $client_secret = '8f7dd22187d5438b823949fca0d8f05e'

    $headers = @{
        "Authorization" = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${client_id}:$client_secret")))"
    }

    $body = @{
        "grant_type" = "client_credentials"
        "scope" = 'user-read-private user-read-email user-modify-playback-state'
    }

    $response = Invoke-WebRequest -Uri "https://accounts.spotify.com/api/token" -Method POST -Headers $headers -Body $body -ContentType "application/x-www-form-urlencoded"

    if ($response.StatusCode -eq 200) 
    {
        $token = ($response.Content | ConvertFrom-Json).access_token
        return $token
    }

}
function getid()
{
    $accestoken = request_token
    $headers = @{  
        "Accept" = "application/json"
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $accestoken"
    }

    $data = Invoke-WebRequest -Uri "https://api.spotify.com/v1/search?q='$musique'%2520artist%3A'$artiste'&type=track" -Method GET -Headers $headers
    $data = ($data.Content) |ConvertFrom-Json
    $data
    $id = $data.tracks.items.id[0]
    return $id
}

getid
# $code = $Error.Item(0) | ConvertFrom-Json
# $code.error.status
