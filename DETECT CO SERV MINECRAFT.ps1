Add-Type -AssemblyName System.Speech
$synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
$i=0
while ($true) {
    if ($i -eq 1){break}
    Start-Sleep -Seconds 3
    $players = Invoke-RestMethod -Uri "https://panel.omgserv.com/json/398902/players"
    switch -Exact -CaseSensitive ($players.players) {
        "morgxnnne" {$synthesizer.Speak("Morganne c'est connecter");$i = 1;break}
        "RdegatsBruts" {$synthesizer.Speak("Marius c'est connecter");$i = 1;break}
    }
}


