# Définir l'adresse IP et le port du serveur auquel vous souhaitez vous connecter
$serverIP = "127.0.0.1"
$serverPort = 50000


# Créer un objet de socket TCP
$tcpClient = New-Object System.Net.Sockets.TcpClient

# Tenter de se connecter au serveur
try {
    $tcpClient.Connect($serverIP, $serverPort)
    Write-Host "Connecté au serveur sur $serverIP : $serverPort"
    
    # Vous pouvez maintenant envoyer et recevoir des données via le $tcpClient
    while(1)
    {
        $data = ""
        
        # Exemple d'envoi de données
        while($data.Length -eq 0)
        {   #ne pas envoyer si data est vide
            $data = $(Read-Host("$ "))
            $dataInByte = [System.Text.Encoding]::ASCII.GetBytes($data)
        }
        #si data est un module ne pas envoyer
        if($data -in "cls","clear","exit")
        {
            switch($data)
            {
                {$_ -in ("cls","clear")}{Clear-Host;"faf";break}
                "exit"{"afaf";$tcpClient.Close();exit}
            }
            continue
        }
        #envoie data
        $tcpClient.GetStream().Write($dataInByte, 0, $dataInByte.Length)
        
        # Exemple de réception de données
        $buffer = New-Object byte[] 9999
        $bytesRead = $tcpClient.GetStream().Read($buffer, 0, $buffer.Length)
        Write-Host $bytesRead
        $receivedData = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)
        Write-Host "$receivedData"
    }
}
catch {
    Write-Host "Erreur de connexion : $_.Exception.Message"
}