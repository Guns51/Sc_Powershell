$client_id = '10d30621aa8745b986b498752f608d2f'
$client_secret = '8f7dd22187d5438b823949fca0d8f05e'
$redirect_uri = 'https://kichonvebin/callback/'

$scope = 'user-read-private user-read-email user-modify-playback-state'
$query = 'response_type=code&client_id=' + $client_id + '&scope=' + $scope + '&redirect_uri=' + $redirect_uri
$url = 'https://accounts.spotify.com/authorize?' + $query
$url

