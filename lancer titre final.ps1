$client_id = '10d30621aa8745b986b498752f608d2f'
$client_secret = '8f7dd22187d5438b823949fca0d8f05e'
$redirect_uri = 'https://kichonvebin/callback/'

$token = 'BQAShxEBsbe-SEZzyTK-FreLJlWKpOiWPxGVBT0MD922eg7x52EtJU2jemz-WvQgcwcmgVSRLAbf2lT23hpJ52XnLmQ8FoMeg8o570hvyvQ-BLzw--2r1Hwe4IwjDaFBfU7R1ryIf1DhvBkHOH29v_zDVshV0eQNbb51hjv22Bx0PKtNExk8jT2jnwD7HcQA2P47Wm1IOINARk3gs1KrAj3sbc43Oh8_i7cWyH4lN_NHQMFSkiLUFxpzPPZ26qqZAkRPrquVCQ4m_c2-1Z5SjIqqDDCSmahYu5Pan_1r8EnOVjijEfwwn6ZLG4EQpxRnDA'

$headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $token"
}
$data = "{`"uris`":[`"spotify:track:0fukO3WYYUHaXOrvEohpEG`"]}"
  
Invoke-RestMethod -Method PUT -Uri "https://api.spotify.com/v1/me/player/play" -Headers $headers -Body $data