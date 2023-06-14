$key = 'RGAPI-27102097-910e-4140-889d-4791e4200024'
$nomJoueur = "PietraDelFall"

$gameMode = @{
    'draft'= '400'
    'solo'= '420'
    'blind'= '430'
    'flex'= '440'
    'aram'= '450'
}

$headers = @{
    "Origin"= "https://developer.riotgames.com"
    "Accept-Charset"= "application/x-www-form-urlencoded; charset=UTF-8"
    "X-Riot-Token"= $key
    "Accept-Language"= "en-us"
    "User-Agent"= "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15"
}

function getIdChampion($IDChamp)
{ 
    if (!$Script:ListChamp)
    {
        $Script:ListChamp = @{}
        $response = Invoke-RestMethod -Uri "http://ddragon.leagueoflegends.com/cdn/13.1.1/data/en_US/champion.json"    
        $data = $response.data
        foreach ($item in $data.psobject.Properties.Value) {$Script:ListChamp[$item.key] = [PSCustomObject] $item.name}   
    }
    $Script:ListChamp."$IDChamp"  
}

function IDorPUID($Choix)  
{
    $requestname = Invoke-WebRequest -Uri ("https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/"+ $nomJoueur + "?api_key=$key")
    $requestname = ($requestname.Content |ConvertFrom-Json)
    $id = $requestname.id
    $puid = $requestname.puuid
    if ($Choix -eq 'id'){return $id} elseif ($Choix -eq 'puid'){return $puid} else {Write-Output("Mauvais parametre pour IDorPUID")}
}

function statsRanked()
{
    $id = IDorPUID('id')
    $requeststats = Invoke-RestMethod -Uri ("https://euw1.api.riotgames.com/lol/league/v4/entries/by-summoner/"+ $id) -Headers $headers
    $winrate = [string](($requeststats.wins/($requeststats.wins + $requeststats.losses))*100) + " %"
    return $requeststats, $winrate
}

Function convertWinToInt($result)
{
    switch ($result)
    {
        "True" {return 1}
        "False" {return 0}
    }
}

function getIDGame($nomGameMode)
{
    
    $puid = IDorPUID("puid")
    $IntMode = $gameMode.$nomGameMode
    $params = "ids?queue=$IntMode&start=0&count=20"
    $url = "https://europe.api.riotgames.com/lol/match/v5/matches/by-puuid/$puid/$params"
    Invoke-RestMethod -Uri $url -Headers $headers | ForEach-Object{$tabIDGame+= @($_)}
    Return $tabIDGame
}

function getWinRateChamp($nomGameMode)
{
    $i = 0
    $tabWinChamp = @{}
    $puid = IDorPUID("puid")
    getIDGame($nomGameMode) | ForEach-Object -Process{
                                $i++
                                $data = Invoke-RestMethod -Uri ("https://europe.api.riotgames.com/lol/match/v5/matches/"+ $_) -Headers $headers
                                $data = $data.info.participants | ? puuid -EQ $puid
                                $tabWinChamp[$data.championId] += convertWinToInt($data.win)
                                $i
                                if ($i%20 -eq 0){Start-Sleep -Seconds 1}
                              }
    $tabWinChamp
}
getWinRateChamp('solo')

# "id": "d1EsMz9K2OmqH16wmI1gVihsLA5Bk1hJu8ATOAkR4mlMT8lB",
# "accountId": "FpDXl6Cg7Afej7ldNKclSbo5hGvloZ2MJWdj0HAc8V-Syebck3-PFYw0",
# "puuid": "mjHfPgx8axvGIZyM_bN0fNSMhvbxWeDqIFTDLz5TRuU8wOSQm99tOO_6GhsN_xGu7cmDNDkh25bHGw"
# https://euw1.api.riotgames.com/lol/league/v4/entries/by-summoner/-6AheGnQhJsQdZdCoOU_KHcrOyqa0mH_VqiZVxeYBYQVVdy2An7uZkW1Gg?api_key=RGAPI-139131c4-0270-4392-b2ff-cc64622c8b55
# https://euw1.api.riotgames.com/lol/summoner/v4/summoners/by-name/CasserDesTours
# El psŸ congroo
# https://developer.riotgames.com/
