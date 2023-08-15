if(!(Get-Process -Name LeagueClientUx -ErrorAction SilentlyContinue))
{
    Write-Warning $Error[0].Exception.Message
    exit    
}

#creation dossier de log
try {
    New-Item -ItemType Directory -Name "AppStatLol" -Path "$env:ProgramData" -ErrorAction SilentlyContinue
    New-Item -ItemType File -Name "resultStat.csv" -Path "$env:ProgramData\AppStatLol" -ErrorAction SilentlyContinue
}
catch {
    Write-Error $_.Exception.Message
}
################################---Partie pour ne pas verifier le certicat SSL---#####################################
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
######################################---Definition variable pour web request---#####################################
function GET 
{
    param([string]$endPoint,$ErrorState)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Get -Headers $headers -ErrorAction $ErrorState
}
function POST 
{
    param([string]$endPoint,$ErrorState)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Post -Headers $headers
}
function PUT 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Put -Headers $headers
}
############################---Definition variable de jeu---##########################################
$startArgument = (Get-CimInstance -Class Win32_Process -Filter "Name='LeagueClientUx.exe'").CommandLine
$appPort = ($startArgument |Select-String -Pattern '--app-port=\d+' -AllMatches ).Matches.Value.Substring(11)
$password = ($startArgument |Select-String -Pattern '--remoting-auth-token=(.+?)(?=")').Matches.Value.Substring(22)
$tokenAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("riot:$password"))
$headers = @{"Authorization"= "Basic $tokenAuth"}
#######################################################################################################################

#######################################################################################################
###                                                                                                 ###
###############################---Parti pour le gameflow avec un job ---###############################
###                                                                                                 ###
#######################################################################################################
$scGameFlow = {

    param($appPort,$headers)

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
    function GET 
    {
        param([string]$endPoint)
        Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Get -Headers $headers
    }
    
    while($true)
    {
        GET /lol-gameflow/v1/gameflow-phase
        sleep 2
    }
}
#Lance le job pour la gameFlow
Start-Job -Name "jobState" -ScriptBlock $scGameFlow -PSVersion 5.1 -ArgumentList $appPort,$headers


##################---fonction pour faire le ratio---###############
function ratio
{
    param($win,$gamePlayed)
    if ($gamePlayed[0] -eq "0")
    {
        return "NULL"
    }
    else{
        #$ratio = [string]([math]::Truncate(([int]$win / [int]$gamePlayed)*100))+"%"
        [string]$ratio = [math]::Round(([int]$win / [int]$gamePlayed)*100)
        return ("$ratio%")
    }
}

#######################################################################################################
###                                                                                                 ###
########---fonction "calculStats" pour recupérer les stats d'une saison pour une personne ---##########
###                                                                                                 ###
#######################################################################################################
function calculStats #return hashtable avec nbWIN et nbPlayed
{
    param ([string]$selectSeason)
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


##############################################################################################################################################################################################################
######                                                                                                                                                                                                  ######
##########################################################################---Debut switch principal ---#######################################################################################################
######                                                                                                                                                                                                  ######
##############################################################################################################################################################################################################
while ($true)
{
    switch ((Receive-Job jobState -ErrorAction Stop)| select -Last 1) 
    {
        #si fait rien
        "None" {$_;Start-Sleep -Seconds 3;break}
        #si dans lobby et fait rien
        "Lobby" {$_;Start-Sleep -Seconds 1;break}
        #si recherche une partie
        "Matchmaking" {$_;Start-Sleep -Seconds 1;break}
        #si partie trouvée : Accepter
        "ReadyCheck" {
            $_
            #envoie des post en boucles meme si queue deja accept
            try {
                POST /lol-matchmaking/v1/ready-check/accept -ErrorState Ignore
                POST /lol-lobby-team-builder/v1/ready-check/accept -ErrorState Ignore
            }
            catch {Write-Warning "postGame(possible fail)"}
            break
        }
        #si dans champ select
        "ChampSelect" {$_;Start-Sleep -Seconds 3;break}
        #si dans la game
        "InProgress" {
            $_
            #recupération de la game en cours
            $gameSession = (GET /lol-gameflow/v1/session)
            #type de game en cours
            $typeGame = $gameSession.gamedata.queue.id
            #id de game
            $gameId = $gameSession.gameData.gameId
            #si type de game n'est pas une draft ou ranked :
            if(!($typeGame -cin "400","420","440")) #{400 = 5v5 Draft Pick games; 420 = RANKED_SOLO_5x5; 440 = 5v5 Ranked Flex games}
            {
                Start-Sleep -Seconds 2
                while(((Receive-Job jobState)| select -Last 1) -cin "InProgress")#si le status est InProgress : attendre 
                {   
                    Write-Host "attenteFinDeGameNonValid"
                    Start-Sleep 5  
                }
                break     
            }
            #######################################################################################################
            ###                                                                                                 ###
            ##################################---Definition de variables---########################################
            ###                                                                                                 ###
            #######################################################################################################
            switch ($typeGame)#definition du game mode
            {
                "400" {$gameMode = "draft5"}
                "420" {$gameMode = "rank5solo"}
                "440" {$gameMode = "rank5flex"}
            }
            $currentPuuid = (GET /lol-summoner/v1/current-summoner).puuid
            $teamOne = $gameSession.gameData.teamOne
            $teamtwo = $gameSession.gameData.teamTwo
            $gameId = $gameSession.gameData.gameId
            $compteur = 0
            $tableauStats = New-Object System.Collections.Specialized.OrderedDictionary
            $currentUserTeam = 0
            $tabMoyenne = @()
            $moyenneTeamOne = @()
            $moyenneTeamTwo = @()
            #id de la saison actuelle
            $currentSaisonId = (GET /lol-ranked/v1/splits-config).currentSeasonId
            ###################################################################################################################
            #####                                                                                                         #####
            #############---Partie qui va créer la partie "teamOne" et "teamTwo" dans la hashtable "tableauStat"--#############
            #####                                                                                                         #####
            ###################################################################################################################

            $teamOne,$teamTwo | % {#Pour chauqe teams :
                #$compteur sert a savoir quelle team est concernée (1 = teamOne, 2 = teamTwo)
                $compteur++
                if($currentPuuid -cin $_.puuid)
                {
                    #pour savoir a quelle team appartient l'utilisateur local
                    $currentUserTeam = $compteur
                } 
                $_ | % {#Pour chaque joueurs : 

                    $puuid = $_.puuid
                    $lastSeasonId = [int]$currentSaisonId - 1
                    #bloc pour definir le role du joueur
                    [string]$position = $_.selectedPosition
                    #si mid ou support le nom diffère
                    switch ($position)
                    {
                        "MIDDLE" {$position = "MID"}
                        "UTILITY" {$position = "SUPPORT"}
                    }
                    $id = $_.championId

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
                    #svoir quel membre de quelle team est en cours 
                    switch ($compteur) 
                    {
                        1 { [string]$team = "teamOne";if($currentUserTeam -eq 1){$team = "teamOne (You)"}}
                        2 { [string]$team = "teamTwo";if($currentUserTeam -eq 2){$team = "teamTwo (You)"} }
                    }

                    Write-Host $team
                    #tableau recapitulatif
                    $tableauStats[$team] += @{
                                    $position = $statsCombine
                    } 
                
                }
            }


            ###################################################################################################################
            #####                                                                                                         #####
            #################---Partie qui va créer la partie "resume" dans la hashtable "tableauStat"--#######################
            #####                                                                                                         #####
            ###################################################################################################################

            $tableauStats["resume"] = @{}
            Write-Host "debut resume"
            $tableauStats.keys -match "team" | %{
                $teamGlobalStats = $_
                "ChampionSummary","PositionSummary","QueueSummary" | % {
                    $facteurTotal = 0
                    $nbPlayedTotal = 0
                    $summaryTree = $_
                    "TOP","JUNGLE","MID","BOTTOM","SUPPORT" | % {
                        $positionTree = $_
                        $winrate = $tableauStats."$($teamGlobalStats)".$($positionTree).$($summaryTree).winrate
                        Write-Host $winrate 'winrate'
                        if($winrate -eq "NULL"){continue}
                        #retirer le "%"
                        [int]$intWinrate = ($winrate | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                        [int]$nbPlayed = $tableauStats."$($teamGlobalStats)".$($positionTree).$($summaryTree).nbPlayed
                        Write-Host $nbPlayed 'nbPlayed'
                        [int]$nbPlayedTotal += $nbPlayed
                        Write-Host $nbPlayedTotal 'nbPlayedTotal'
                        [int]$facteurTotal += ($intWinrate*$nbPlayed)
                        Write-Host $facteurTotal 'facteurTotal'
                    }
                    Write-Host "summary $_"
                    $resumePourcentage = [math]::Round($facteurTotal/$nbPlayedTotal)
                    $tableauStats["resume"][$teamGlobalStats] += @{"$_" = [string]$resumePourcentage + "%"}
                } 
                Write-Host "teamResume"
                ####calcul moyenne des summary pour chaque team####
                $team = "$_"
                $D = $tableauStats.resume.$team
                [int]$champion = ($D.ChampionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                [int]$position = ($D.PositionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                [int]$queue = ($D.QueueSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                #index 0 = teamOne ||| index 1 = teamTwo
                $tabMoyenne += ([math]::Round(($champion+$position+$queue)/3))
                Write-Host "tabMoyenne"
                }
                #apres avoir fait la moyenne : savoir quelle est la plus grande ou egale
                if($tabMoyenne[0] -gt $tabMoyenne[1])#si teamOne plus grand que teamTwo
                {
                    $theoricWinner = 1
                }
                else {
                    if ($tabMoyenne[0] -lt $tabMoyenne[1])#si teamTwo plus grand que teamOne
                    {
                        $theoricWinner = 2
                    }
                    else #si egalité
                    {
                        $theoricWinner = "="
                    }
                }
            $moyenneTeamOne += $tabMoyenne[0]
            $moyenneTeamTwo += $tabMoyenne[1]
            Write-Host "debut display"   
            
            ###################################################################################################################
            #####                                                                                                         #####
            ####################---Partie qui va créer la partie display pour l'affichage des stats--##########################
            #####                                                                                                         #####
            ###################################################################################################################

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

            ###################################################################################################################
            #####                                                                                                         #####
            ############################---Partie pour l'inventorisation des stats post game--#################################
            #####                                                                                                         #####
            ###################################################################################################################

            ###---Une fois la recuperation des stats effectuées : attendre la fin de la game---###


            while(((Receive-Job jobState)| select -Last 1) -cin "InProgress")#Tant que le gameFlow est toujours en "InProgress" : attendre
            {
                    Start-Sleep -Seconds 10
                    Write-Host "attenteFinDeGamePourStatDansHtml"
            }
            ###---Recuperation du gagnant---###
            while($true)
            {
                try {#si la team 100 (teamOne) a gagnée :
                    if(((GET /lol-match-history/v1/games/$gameId -ErrorState Stop).teams[0].win) -eq "Win") #(1 pour teamOne et 2 pour teamTwo)
                    {
                        $winner = 1
                    }
                    else{$winner = 2}
                    break
                }
                catch 
                {}
                Start-Sleep -Seconds 1
            }
            

            ###############################----Construction du HTML,CSS,JAVASCRIPT---#############################
            $tableauStats.keys -match "team" | %{
                $team = "$_"
                $D = $tableauStats.resume.$team
                $champion = ($D.ChampionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                $position = ($D.PositionSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                $queue = ($D.QueueSummary | Select-String -Pattern '\d+' -AllMatches).Matches.Value
                # Charger le contenu actuel du fichier HTML s'il existe, sinon créer le contenu initial
                if(!(Test-Path "$env:USERPROFILE\documents\lolStat\"))
                {
                    New-Item -ItemType Directory -Path "$env:USERPROFILE\documents\lolStat\" -Force
                }
                $pathResult = "$env:USERPROFILE\documents\lolStat\resultats.html"
                if (!(Test-Path $pathResult))  {
                    $html = @"
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Resultat des estimations</title>
                    <script>
                    window.onload = function calculatePercentage() {
                        var totalGagnant = 0;
                        var totalCells = 0;
                        var totalGame = 0;
                        var rightPredict = 0;

                        //pour couleur des .data
                        var data = document.querySelectorAll('.data');
                        data.forEach(element => {
                            var content = element.innerHTML.match(/\d+/)[0];
                            if(content > 50)
                            {element.style.color = "green";}
                            else{
                                if (content < 50) {
                                    element.style.color = "firebrick";
                                } else {
                                    element.style.color = "darkgoldenrod";
                                }
                            }
                            })
                        //pour couleur des lignes (en gris)
                        var rows = document.querySelectorAll('#resultatsTable tbody tr');
                        for (let i = 0; i < rows.length-1; i += 4) {
                            rows[i].style.backgroundColor = "#212020";
                            rows[i + 1].style.backgroundColor = "#212020";
                        }
                        //pour calculer le pourcentage de bonne predictions
                        for(let i = 0; i < rows.length-1; i+=2)
                        {
                            totalGame += 1;
                            let winnerTheoric = rows[i].getElementsByClassName("theoricWinner")[0].innerHTML;
                            let winner = rows[i].getElementsByClassName("winner")[0].innerHTML;
                            if (winnerTheoric === winner)
                            {
                                rightPredict += 1;
                            }
                        }
                        var predict = ((rightPredict/totalGame)*100).toFixed(2) + "%";
                        document.querySelector('.fixed-box_content').textContent = predict;
                    }
                    </script>
                    <style>
                    body{background-color: rgb(27, 26, 26);
                        font-family:"Roboto", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
                        font-weight: bold;}
                    h1{color: lightskyblue;text-align: center;}
                    p{color: darkorchid;}
                    .data {color:lightskyblue;font-weight: bold;text-align: center;}
                    thead{color: white;text-transform: uppercase;display: table-header-group;letter-spacing: 0.3rem;}
                    .team {color:cadetblue;text-align: center;}
                    th,td,tr {padding: 0.3rem;}
                    tr {display: table-row;}
                    table {display: table;border-collapse: collapse;margin-left: 3%;width: 70%;}
                    td {display: table-cell;}
                    .theoricWinner,.winner {text-align: center;color: aqua;}
                    .moyenne {color: salmon;text-align: center;}
                    .fixed-box {top: 35%;position: fixed;right: 10%;color: rgb(6, 168, 93);border: 2px solid goldenrod;text-align: center;padding: 0.5rem;}
                    .fixed-box_content {color: aquamarine;}
                    </style>
                </head>
                <body>
                    <h1>Resultat des estimations</h1>
                    <table id="resultatsTable">
                        <thead>
                            <tr>
                                <th>Team</th>
                                <th>Champion</th>
                                <th>Position</th>
                                <th>Queue</th>
                                <th>Moyenne</th>
                                <th>Gagnant<br>Theorique</th>
                                <th>Gagnant<br>Reel</th>
                            </tr>
                        </thead>
                    </table>
                    <div class="fixed-box">
                        ResultPredict
                        <div class="fixed-box_content"></div>
                    </div>
"@
                $html | Set-Content -Path $pathResult -Encoding UTF8 -Force
                } 
                else {
                    $html = Get-Content -Path $pathResult -Raw -Encoding UTF8 -Force
                }

                # Générer la nouvelle ligne du tableau en utilisant les données
                if (($team.Substring(0,7)) -eq "teamOne") {
                $nouvelleLigne = @"
                <tr>
                    <td class="team">$team</td>
                    <td class="champion data">$($champion)%</td>
                    <td class="position data">$($position)%</td>
                    <td class="queue data">$($queue)%</td>
                    <td class="moyenne">$($moyenneTeamOne)%</td>
                    <td rowspan="2" class="theoricWinner">$theoricWinner</td>
                    <td rowspan="2" class="winner">$winner</td>
                </tr>
"@
                }
                else
                {
                $nouvelleLigne = @"
                <tr>
                    <td class="team">$team</td>
                    <td class = "champion data">$($champion)%</td>
                    <td class="position data">$($position)%</td>
                    <td class="queue data">$($queue)%</td>
                    <td class="moyenne">$($moyenneTeamTwo)%</td>
                </tr>
"@
                }
                # Ajouter la nouvelle ligne à la fin du tableau
                $html = $html -replace "</table>", "$nouvelleLigne`n</table>"

                # Écrire le contenu HTML mis à jour dans le fichier
                $html | Set-Content -Path $pathResult -Encoding UTF8

                Write-Host "Une nouvelle ligne a été ajoutée au fichier 'resultats.html' avec succès."
            }

            Write-Host "fin post game"
            Start-Sleep -Seconds 2
            break
        }
        
        #en attente des stats
        "WaitingForStats" {$_;Start-Sleep -Seconds 3;break}
        #si dans stat de fin de game
        "EndOfGame" {break}
        Default {$_;Start-Sleep -Seconds 10;break}
    }
}
