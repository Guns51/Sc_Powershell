"teamOne","teamTwo"|ForEach-Object{  
    $team = "$_"
    $champion = "NouveauChampion"
    $position = "NouvellePosition"
    $queue = 80
    $gagnant = "1"

    # Charger le contenu actuel du fichier HTML s'il existe, sinon créer le contenu initial
    if (!(Test-Path "resultats.html"))  {
        $html = @"
    <!DOCTYPE html>
    <html>
    <head>
        <title>Résultats du tableau</title>
        <script>
        window.onload = function calculatePercentage() {
            var totalGagnant = 0;
            var totalCells = 0;
            var totalGagnantTd = document.querySelectorAll('.winner');

            for (var i = 0; i < totalGagnantTd.length; i++) {
                totalCells++;
                if (totalGagnantTd[i].innerText === '2') {
                    totalGagnant++;
                }
            }   
            var totalPercentage = ((totalGagnant / totalCells) * 100)+"%";
            var poucentageCell = document.getElementById("poucentageCell");
            poucentageCell.textContent = totalPercentage
        }
        </script>
    </head>
    <body>
        <h1>Résultats sous forme de tableau</h1>
        <table id="resultatsTable" border="2">
            <tr>
                <th>Team</th>
                <th>Champion</th>
                <th>Position</th>
                <th>Queue</th>
                <th>Gagnant</th>
            </tr>
            <p>Total des âges : <span id="poucentageCell"></span></p>
        </table>
"@
    $html | Set-Content -Path "resultats.html" -Encoding UTF8
    } else {
        $html = Get-Content -Path "resultats.html" -Raw
    }

    # Générer la nouvelle ligne du tableau en utilisant les données
    if (($team.Substring(0,7)) -eq "teamOne") {
        $nouvelleLigne = @"
            <tr>
                <td>$team</td>
                <td>$champion</td>
                <td>$position</td>
                <td class="queue">$queue</td>
                <td rowspan="2" class="winner" >$gagnant</td>
            </tr>
"@
    }
    else
    {
        $nouvelleLigne = @"
            <tr>
                <td>$team</td>
                <td>$champion</td>
                <td>$position</td>
                <td class="queue">$queue</td>
            </tr>
"@
    }
    # Ajouter la nouvelle ligne à la fin du tableau
    $html = $html -replace "</table>", "$nouvelleLigne`n</table>"

    # Écrire le contenu HTML mis à jour dans le fichier
    $html | Set-Content -Path "resultats.html" -Encoding UTF8

    Write-Host "Une nouvelle ligne a été ajoutée au fichier 'resultats.html' avec succès."
}