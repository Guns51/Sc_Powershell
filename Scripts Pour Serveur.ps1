Function generique
{
    $t = New-Object -TypeName System.Timers.Timer
    $t.Start()
    Start-Sleep 2
    $t
}












################################################################################################################################################
Function scriptForDnsCache #Récupere cache dns toutes les 30 secondes et va mettre le resultat dans BDD du serveur
{
    $donnee = "sudo mysql << EOF
    USE Historique
    INSERT INTO trucBizarre (id, heure, site) 
    VALUES "

    $oldCache = Get-DnsClientCache -Type A | Select-Object -Unique -Property Entry, TimeToLive
    Start-Sleep -Seconds 30
    $newCache = Get-DnsClientCache -Type A | Select-Object -Unique -Property Entry, TimeToLive
    $newSiteDns = Compare-Object -ReferenceObject $oldCache -DifferenceObject $newCache -Property Entry
    $date = Get-Date -UFormat "%d/%m/%Y %R"
    $newSiteDns.Entry |
    ForEach-Object -Begin $null -Process {$donnee += "(NULL, '$date', '$_'),"} -End {$donnee = $donnee.Remove($donnee.Length-1) +";"}
    $donnee

    ssh -o "StrictHostKeyChecking no" 13.39.106.145
    ssh -i "$env:SystemRoot/Nasus/cle.pem" admin@13.39.106.145 -t ($donnee)
}

################################################################################################################################################

generique