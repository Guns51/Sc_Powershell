if(!(Get-Process -Name LeagueClientUx -ErrorAction SilentlyContinue))
{
    Write-Warning $Error[0].Exception.Message
    exit    
}

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
function POST 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Post -Headers $headers
}
function PUT 
{
    param([string]$endPoint)
    Invoke-RestMethod -Uri "https://127.0.0.1:$appPort$endPoint" -Method Put -Headers $headers
}
$startArgument = (Get-CimInstance -Class Win32_Process -Filter "Name='LeagueClientUx.exe'").CommandLine
$appPort = ($startArgument |Select-String -Pattern '--app-port=\d+' -AllMatches ).Matches.Value.Substring(11)
$password = ($startArgument |Select-String -Pattern '--remoting-auth-token=(.+?)(?=")').Matches.Value.Substring(22)
$tokenAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("riot:$password"))
$headers = @{"Authorization"= "Basic $tokenAuth"}

# https://www.mingweisamuel.com/lcu-schema/tool/#/Plugin%20lol-chat/PutLolChatV1ConversationsById
#GET /lol-chat/v1/conversations
$a = GET /lol-chat/v1/me