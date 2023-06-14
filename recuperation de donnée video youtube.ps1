# Remplacez YOUR_API_KEY par votre clé d'API YouTube
$API_KEY = "AIzaSyDwajYGvzf3kwXLsfinAH9sHvQoMALzMwM"

# Remplacez CHANNEL_ID par l'ID de la chaîne YouTube que vous voulez surveiller
$CHANNEL_ID = "UCXNNkC-eyYEHt7FYuyS0iPw"

# Envoyez une requête à l'API de statistiques de YouTube pour récupérer le nombre de vues totales de la chaîne
$response = Invoke-WebRequest -Uri "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$CHANNEL_ID&key=$API_KEY" -UseBasicParsing

# Extrayez le nombre de vues totales de la réponse
$view_count = ($response.Content | ConvertFrom-Json).items[0].statistics.viewCount

# Affichez le nombre de vues totales
Write-Output "View count: $view_count"

Pause
