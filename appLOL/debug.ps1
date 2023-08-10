if(!(Get-Process -Name LeagueClientUx -ErrorAction SilentlyContinue))
{
    Write-Warning $Error[0].Exception.Message
    exit    
}
#######################################################################################################################
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#######################################################################################################################
function GET 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Get -Headers $headers -ErrorAction Stop
}
function POST 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Post -Headers $headers -ErrorAction Stop
}
function PUT 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Put -Headers $headers -ErrorAction Stop
}

$startArgument = (Get-CimInstance -Class Win32_Process -Filter "Name='LeagueClientUx.exe'").CommandLine
$appPort = ($startArgument |Select-String -Pattern '--app-port=\d+' -AllMatches ).Matches.Value.Substring(11)
$password = ($startArgument |Select-String -Pattern '--remoting-auth-token=(.+?)(?=")').Matches.Value.Substring(22)
$tokenAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("riot:$password"))
$headers = @{"Authorization"= "Basic $tokenAuth"}

#lance la recherche d'une partie : POST /lol-lobby/v2/lobby/matchmaking/search
#avoir etat de la recherche de partie : GET /lol-lobby/v2/lobby/matchmaking/search-state
#avoir pseudo,puuid,summoner actif : GET /lol-summoner/v1/current-summoner
#avoir puuid,summoner avec nom du joueur : GET /lol-summoner/v1/summoners?name={name}
#savoir si dans un lobby : GET /lol-lobby/v2/party-active
#recupérer plusieur game du joueur : GET /lol-match-history/v1/products/lol/{puuid}/matches?endIndex={nombre de games}
#accepter la queue/partie : POST /lol-matchmaking/v1/ready-check/accept
#avoir resumé d'un seul champion pour game specifique et resumé saison entiere avec un champion : GET /lol-career-stats/v1/summoner-stats/{puuid}/{season}/{queue}/{position}
#avoir etat du jeu (champ select,matchmaking etc (InProgress pour game en cours ou chargement)) : GET /lol-gameflow/v1/gameflow-phase

$gameSession = Get-Content -Path "C:\Users\gunsa\Desktop\Sc_Powershell\vartest.txt" | ConvertFrom-Json
#type de game
$typeGame = $gameSession.gamedata.queue.id
Write-Host "type de game : $typeGame"
#si type de game est une draft ou ranked :
if($typeGame -cin "400","420","440") #{400 = 5v5 Draft Pick games; 420 = RANKED_SOLO_5x5; 440 = 5v5 Ranked Flex games}
{
    switch ($typeGame) 
    {
        "400" {$gameMode = "draft5"}
        "420" {$gameMode = "rank5solo"}
        "440" {$gameMode = "rank5flex"}
    }
    #puuid du joueur local
    $currentPuuid = (GET /lol-summoner/v1/current-summoner).puuid

    #fonction pour faire le ratio
    function ratio
    {
        param($win,$gamePlayed)
        if ($gamePlayed[0] -eq "0")
        {
            return "NULL"
        }
        else{
            #$ratio = [string]([math]::Truncate(([int]$win / [int]$gamePlayed)*100))+"%"
            [string]$ratio = [math]::Truncate(([int]$win / [int]$gamePlayed)*100)
            return ("$ratio%")
        }
    }
    ########################---Bloc prinpale pour calcul stat---##################################################
    $teamOne = $gameSession.gameData.teamOne
    $teamtwo = $gameSession.gameData.teamTwo
    $compteur = 0
    $tableauStats = New-Object System.Collections.Specialized.OrderedDictionary
    $currentUserTeam = 0
    
    #id de la saison actuelle
    $currentSaisonId = (GET /lol-ranked/v1/splits-config).currentSeasonId
    function calculStats #return hashtable
    {
        param ([string]$selectSeason)
        #debug
        Write-Host "debut fonction calculstats"
        #recupere stat de la personne pour la saison active
        try #test pour ChampionSummary
        {
            $stats = GET /lol-career-stats/v1/summoner-stats/$puuid/$selectSeason/$gameMode/$($position)?championId=$id
            Write-Host "calculstatpostStats(try1)"
            #recuperation des stats
            $ChampionSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).positionSummaries.$($position).championSummary."$($id)".stats."CareerStats.js" #championSummaryForLane
            $PositionSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).positionSummaries.$($position).positionSummary.stats."CareerStats.js" #positionSummary
            $QueueSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).queueSummary.stats."CareerStats.js" #queueSummary
            
            return @{ChampionSummary = @{
                                nbWIN = $ChampionSummary.victory
                                nbPlayed = $ChampionSummary.gamePlayed}
                        PositionSummary = @{
                                nbWIN = $PositionSummary.victory
                                nbPlayed = $PositionSummary.gamePlayed}
                        QueueSummary = @{
                                nbWIN = $QueueSummary.victory
                                nbPlayed = $QueueSummary.gamePlayed}
                    }
        }
        catch 
        {
            try #test pour PositionSummary
            {
                $stats = GET /lol-career-stats/v1/summoner-stats/$puuid/$selectSeason/$gameMode/$($position)
                Write-Host "calculstatpostStats(try2)"
                #recuperation des stats
                $PositionSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).positionSummaries.$($position).positionSummary.stats."CareerStats.js" #positionSummary
                $QueueSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).queueSummary.stats."CareerStats.js" #queueSummary

                return @{ChampionSummary = @{nbWIN = 0;nbPlayed = 0}
                            PositionSummary = @{
                                    nbWIN = $PositionSummary.victory
                                    nbPlayed = $PositionSummary.gamePlayed}
                            QueueSummary = @{
                                    nbWIN = $QueueSummary.victory
                                    nbPlayed = $QueueSummary.gamePlayed}
                        }    
            }
            catch 
            { 
                $correctLane = @()
                #test pour chaque lane pour recupérer QueueSummary
                "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | % {
                    try 
                    {
                        #recuperation des stats
                        $stats = (GET /lol-career-stats/v1/summoner-stats/$puuid/$selectSeason/$gameMode/$($_))
                        Write-Host "calculstatpostStats(try3) $_"
                        #pour savoir quelles lane marche
                        $correctLane += $_
                    }
                    catch {}
                }
                try #test pour QueueSummary
                {
                    #recuperation des stats avec la premiere lane qui marche
                    $stats = (GET /lol-career-stats/v1/summoner-stats/$puuid/$selectSeason/$gameMode/$($correctLane[0]))
                    Write-Host "calculstatpostStats(try4)"
                    $QueueSummary = $stats.seasonSummary."$($selectSeason)".$($gameMode).queueSummary.stats."CareerStats.js" #queueSummary
                    return @{ChampionSummary = @{nbWIN = 0;nbPlayed = 0}
                            PositionSummary = @{nbWIN = 0;nbPlayed = 0}
                            QueueSummary = @{
                                        nbWIN = $QueueSummary.victory
                                        nbPlayed = $QueueSummary.gamePlayed}        
                    }
                }
                catch #si pas de game pendant la saison
                {
                    Write-Host "lastCatch"
                    return @{ChampionSummary = @{nbWIN = 0;nbPlayed = 0}
                            PositionSummary = @{nbWIN = 0;nbPlayed = 0}
                            QueueSummary = @{nbWIN = 0;nbPlayed = 0}} 
                }
            }
        } 
    }
    ######################################################################################
    $teamOne,$teamTwo | % {
        #$compteur sert a savoir quelle team est concernée
        $compteur++
        if($currentPuuid -cin $_.puuid)
        {
            #pour savoir a quelle team appartient l'utilisateur local
            $currentUserTeam = $compteur
        } 
        $_ | % {
        #################################<-Definition des variables pour requete->################
        $puuid = $_.puuid                                                                   ## 
        $lastSeasonId = [int]$currentSaisonId - 1                                           ## 
        #bloc pour definir le role du joueur                                                ##
        $position = $_.selectedPosition                                                     ##
        #si mid ou support le nom diffère                                                   ##
        switch ($position)                                                                  ##
        {                                                                                   ##
            "MIDDLE" {$position = "MID"}                                                    ##
            "UTILITY" {$position = "SUPPORT"}                                               ##
        }                                                                                   ##
        $id = $_.championId                                                                 ##
        ##########################################################################################
        Write-Host "debut foreach"
        Write-Host $puuid,$position

        $statsCurrentSeason = calculStats $currentSaisonId 
        $statsLastSeason = calculStats $lastSeasonId

        #stats de la saison actuelle additionner avec l'ancienne saison
        $statsCombine = @{
            ChampionSummary = @{
                        nbWIN = [int]($statsCurrentSeason.ChampionSummary.nbWIN + $statsLastSeason.ChampionSummary.nbWIN)
                        nbPlayed = [int]($statsCurrentSeason.ChampionSummary.nbPlayed + $statsLastSeason.ChampionSummary.nbPlayed)
                        winrate = ratio ($statsCurrentSeason.ChampionSummary.nbWIN + $statsLastSeason.ChampionSummary.nbWIN) ($statsCurrentSeason.ChampionSummary.nbPlayed + $statsLastSeason.ChampionSummary.nbPlayed)
                        }
            PositionSummary = @{
                        nbWIN = [int]($statsCurrentSeason.PositionSummary.nbWIN + $statsLastSeason.PositionSummary.nbWIN)
                        nbPlayed = [int]($statsCurrentSeason.PositionSummary.nbPlayed + $statsLastSeason.PositionSummary.nbPlayed)
                        winrate = ratio ($statsCurrentSeason.PositionSummary.nbWIN + $statsLastSeason.PositionSummary.nbWIN) ($statsCurrentSeason.PositionSummary.nbPlayed + $statsLastSeason.PositionSummary.nbPlayed)
                        }
            QueueSummary = @{
                        nbWIN = [int]($statsCurrentSeason.QueueSummary.nbWIN + $statsLastSeason.QueueSummary.nbWIN)
                        nbPlayed = [int]($statsCurrentSeason.QueueSummary.nbPlayed + $statsLastSeason.QueueSummary.nbPlayed)
                        winrate = ratio ($statsCurrentSeason.QueueSummary.nbWIN + $statsLastSeason.QueueSummary.nbWIN) ($statsCurrentSeason.QueueSummary.nbPlayed + $statsLastSeason.QueueSummary.nbPlayed)
                        }
        }
        
        #test pour savoir dans quelle team est le joueur local
        switch ($compteur) 
        {
            1 { [string]$team = "teamOne";if($currentUserTeam -eq 1){$team = "teamOne (You)"}}
            2 { [string]$team = "teamTwo";if($currentUserTeam -eq 2){$team = "teamTwo (You)"} }
        }

        echo $team
        #tableau recapitulatif
        $tableauStats[$team] += @{
                        $position = $statsCombine
        } 
        }
     }

}
function calculGlobalStats
{
    $tableauStats["resume"] = @{}
    $tableauStats.keys -match "team" | %{
        $teamGlobalStats = $_
        "ChampionSummary","PositionSummary","QueueSummary" | % {
            $facteurTotal = 0
            $nbPlayedTotal = 0
            $summaryTree = $_
            "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | % {
                $positionTree = $_
                $winrate = $tableauStats."$($teamGlobalStats)".$($positionTree).$($summaryTree).winrate
                #Write-Host $winrate 'winrate'
                if($winrate -eq "NULL"){continue}
                #retirer le "%"
                [int]$intWinrate = ($winrate | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                [int]$nbPlayed = $tableauStats."$($teamGlobalStats)".$($positionTree).$($summaryTree).nbPlayed
                #Write-Host $nbPlayed 'nbPlayed'
                [int]$nbPlayedTotal += $nbPlayed
                #Write-Host $nbPlayedTotal 'nbPlayedTotal'
                [int]$facteurTotal += ($intWinrate*$nbPlayed)
                #Write-Host $facteurTotal 'facteurTotal'
            }
            $resumePourcentage = [math]::Round($facteurTotal/$nbPlayedTotal)
            $tableauStats["resume"][$teamGlobalStats] += @{"$_" = [string]$resumePourcentage + "%"}
        }  
    }
}
calculGlobalStats

$display = {
    param($tableauStats)
    try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    # Créer une fenêtre Windows Forms
    $form = New-Object Windows.Forms.Form
    $form.Text = "Exemple de TreeView"
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    # Créer un contrôle TreeView
    $treeView = New-Object Windows.Forms.TreeView
    $treeView.Dock = [System.Windows.Forms.DockStyle]::Fill
    ############################
    $treeView.ForeColor = [System.Drawing.Color]::DarkGray
    $treeView.BackColor = [System.Drawing.Color]::Black
    $treeView.Font = New-Object Drawing.Font("Bahnschrift Light", 11, [Drawing.FontStyle]::Regular)
    $treeView.HideSelection = $true
    $treeView.ShowLines = $true
    $treeView.ShowRootLines = $false
    $treeView.ShowRootLines = $true
    $treeView.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $treeView.ItemHeight = 20
    $treeView.FullRowSelect = $true
    $treeView.Indent = 50
    $treeView.LineColor = [System.Drawing.Color]::Cyan
    $treeView.Add_AfterSelect({
        $treeView.SelectedNode = $null
    })
    $treeView.Add_NodeMouseClick({
        $node = $_.Node
        if (-not $node.IsExpanded) {
            $node.Expand()
        }else{$node.Collapse()}
    })

    # Ajouter des nœuds au TreeView
    $rootNodeResume = $treeView.Nodes.Add("Resume")
    $rootNode = $treeView.Nodes.Add("Game")
    $rootNode.BackColor = [System.Drawing.Color]::DarkBlue
    $rootNode.ForeColor = [System.Drawing.Color]::LightCyan
    $tableauStats.keys -match "team" | %{
        $teamTree = $_
        $childNode = $rootNode.Nodes.Add("$_") #teams
        #$tabForStatsPostGame = @{}
        ##############################---Arbre "GAME"---#########################################
        "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | % {
            $positionTree = $_
            $childNode1 = $childNode.Nodes.Add("$_")
            "ChampionSummary","PositionSummary","QueueSummary" | % {
                $summaryTree = $_
                $childNode2 = $childNode1.Nodes.Add("$_")
                "winrate","nbPlayed","nbWIN" | % {
                    $typeStatTree = $_
                    $childNode3 = $childNode2.Nodes.Add("$_")
                    $childNode4 = $childNode3.Nodes.Add($tableauStats."$($teamTree)".$($positionTree).$($summaryTree).$($typeStatTree))
                    if($typeStatTree -eq "winrate"){
                        $childNode3.Expand()
                        [int]$pourcentage = ($childNode4 |Select-String -Pattern '\d+' -AllMatches).Matches.Value
                        Write-Host $pourcentage
                        $childNode4.NodeFont = New-Object Drawing.Font("Bahnschrift Light",13,[Drawing.FontStyle]::Bold)
                        if($pourcentage -lt 50)
                        {
                            $childNode4.ForeColor = [System.Drawing.Color]::Red
                        }
                        else {
                            if($pourcentage -gt 50)
                            {
                                $childNode4.ForeColor = [System.Drawing.Color]::Green
                            }else{$childNode4.ForeColor = [System.Drawing.Color]::Yellow}
                        }
                    }
                }
            }
        }
        ##############################---Fin Arbre "GAME"---#########################################

        ##############################---Arbre "Resume"---#########################################
        
        $rootNodeResume2 = $rootNodeResume.Nodes.Add("$_")#teams
        "ChampionSummary","PositionSummary","QueueSummary" | % {
            $rootNodeResume3 = $rootNodeResume2.Nodes.Add("$_") #"ChampionSummary","PositionSummary","QueueSummary"
            $resumePourcentage = $tableauStats.resume.$teamTree.$_
            $rootNodeResume4 = $rootNodeResume3.Nodes.Add([string]$resumePourcentage + "%")
            $rootNodeResume4.NodeFont = New-Object Drawing.Font("Bahnschrift Light",13,[Drawing.FontStyle]::Bold)
            if($resumePourcentage -lt 50 )
            {
                $rootNodeResume4.ForeColor = [System.Drawing.Color]::Red
            }
            else {
                if($resumePourcentage -gt 50)
                {
                    $rootNodeResume4.ForeColor = [System.Drawing.Color]::Green
                }else{$rootNodeResume4.ForeColor = [System.Drawing.Color]::Yellow}
            }
        }
        
        ##############################---Fin Arbre "Resume"---#########################################
    }
    $rootNodeResume.Expand() # Dérouler le nœud racine

    # Ajouter le TreeView à la fenêtre
    $form.Controls.Add($treeView)
    $form.ShowDialog()
    }
    catch{return $_}
}
 
Start-Job -ScriptBlock $display -ArgumentList $tableauStats

#################################---Pour Statistic post game---######(Actuellement dans foreach de TEAM)####################################
$tableauStats.keys -match "team" | %{
    $team = "$_"
    $D = $tableauStats.resume.$team
    $champion = ($D.ChampionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
    $position = ($D.PositionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
    $queue = ($D.QueueSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
    $moyenne = ($champion+$position+$queue)/3
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
            //QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
            var test = document.querySelectorAll('.data');
            test.forEach(element => {
                element.style.backgroundColor = "purple";
            })
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
    } 
    else {
        $html = Get-Content -Path "resultats.html" -Raw
    }

    # Générer la nouvelle ligne du tableau en utilisant les données
    if (($team.Substring(0,7)) -eq "teamOne") {
    $nouvelleLigne = @"
    <tr>
        <td class="team">$team</td>
        <td class="champion data">$($champion+"%")</td>
        <td class="position data">$($position+"%")</td>
        <td class="queue data">$($queue+"%")</td>
        <td rowspan="2" class="winner">$gagnant</td>
    </tr>
"@
    }
    else
    {
    $nouvelleLigne = @"
    <tr>
        <td class="team">$team</td>
        <td class = "champion data">$($champion+"%")</td>
        <td class="position data">$($position+"%")</td>
        <td class="queue data">$($queue+"%")</td>
    </tr>
"@
    }
    # Ajouter la nouvelle ligne à la fin du tableau
    $html = $html -replace "</table>", "$nouvelleLigne`n</table>"

    # Écrire le contenu HTML mis à jour dans le fichier
    $html | Set-Content -Path "resultats.html" -Encoding UTF8

    Write-Host "Une nouvelle ligne a été ajoutée au fichier 'resultats.html' avec succès."
}
#################################---Pour Statistic post game (FIN)---##########################################



