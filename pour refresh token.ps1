
$client_id = '10d30621aa8745b986b498752f608d2f'
$client_secret = '8f7dd22187d5438b823949fca0d8f05e'
$refresh_token = 'AQDU_QLeO3Nbrp7avhauXgbBB8vRtkfv2t9VW5OonPWQFHmk5UdNzOQJKKUsPk7kwqSSXI6_WQSGndJVRKXfEKyrCobYkSQpURx16YdQB19fAprQMs4iIurFykT7rMKOXVw'

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $client_id,$client_secret)))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
}

$body = @{
    "grant_type" = "refresh_token"
    "refresh_token" = $refresh_token
}

$response = Invoke-RestMethod -Uri "https://accounts.spotify.com/api/token" -Method "POST" -Headers $headers -Body $body -ContentType "application/x-www-form-urlencoded"

if($response.access_token){
    Write-Output $response.access_token
}
