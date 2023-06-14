# Récupère l'adresse IP de la personne qui se connecte
$IP = $env:SSH_CONNECTION.Split(" ")[0]

# Récupère le nom d'utilisateur de la personne qui se connecte
$USER = (Get-WmiObject Win32_ComputerSystem).UserName

# Affiche une notification avec l'adresse IP et le nom d'utilisateur
[Windows.Forms.MessageBox]::Show("Quelqu'un s'est connecté à votre ordinateur en SSH avec l'adresse IP $IP et le nom d'utilisateur $USER.")
