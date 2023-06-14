$code = "AQDSTaNmRhRJLguD7-28gv-w942Mrxvo_wKfd42SO3_s9lTZDDf_xV1MmvWoJL3DLVu9NQxPGEIsIj4ZVVmT1uRE5O2KUAyJ5atDoSfXW3OMkzvuWsQiT4gCium6Rv-Hi1ebnQ8PRQGLAg7EW7b1I4zay6nxigpuH7d_SvEs-Mo611NQ-ePy7LjY7bAzqcJp0tAH1lnO95hWEm_7fmQs_aVa23kf7y7FLKUAWdoydmNRsNhUHAFdvOGzXijOcv7kuw"

$headers = @{Authorization = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($client_id + ':' + $client_secret))}
$body = @{
code = $code;
redirect_uri = $redirect_uri;
grant_type = 'authorization_code';
}
$response = Invoke-WebRequest -Uri 'https://accounts.spotify.com/api/token' -Method POST -Headers $headers -Body $body -ContentType 'application/x-www-form-urlencoded' -Verbose
$json = $response.Content | ConvertFrom-Json
$json
