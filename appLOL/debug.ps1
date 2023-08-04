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

$gameSession = Get-Content -Path .\vartest.txt | ConvertFrom-Json
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
    $tableauStats = @{}
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

