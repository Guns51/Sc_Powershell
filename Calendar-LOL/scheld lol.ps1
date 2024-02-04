$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
$request = Invoke-RestMethod -UseBasicParsing -Uri "https://esports-api.lolesports.com/persisted/gw/getSchedule?hl=fr-FR&leagueId=98767991302996019%2C100695891328981122" `
-WebSession $session `
-Headers @{
"authority"="esports-api.lolesports.com"
  "method"="GET"
  "path"="/persisted/gw/getSchedule?hl=fr-FR&leagueId=98767991302996019%2C100695891328981122"
  "scheme"="https"
  "accept"="*/*"
  "accept-encoding"="gzip, deflate, br"
  "accept-language"="fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
  "origin"="https://lolesports.com"
  "referer"="https://lolesports.com/"
  "sec-ch-ua"="`"Not_A Brand`";v=`"8`", `"Chromium`";v=`"120`", `"Microsoft Edge`";v=`"120`""
  "sec-ch-ua-mobile"="?0"
  "sec-ch-ua-platform"="`"Windows`""
  "sec-fetch-dest"="empty"
  "sec-fetch-mode"="cors"
  "sec-fetch-site"="same-site"
  "x-api-key"="0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z"
}

$uncomingMatch = $request.data.schedule.events | ? state -eq unstarted
$uncomingMatch_KC = $uncomingMatch | ? {$_.match.teams.code -eq  "KC"}