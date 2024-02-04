$url = 'http://localhost:80/'

# html code
$html = Get-Content "C:\Users\gunsa\Desktop\Sc_Powershell\Calendar-LOL\ClosePage.html"

# start basic web server
$htmlListener = New-Object System.Net.HttpListener
$htmlListener.Prefixes.Add($url)
$htmlListener.Start()
while (!([console]::KeyAvailable)) {
    # process received html request
    $httpContext = $htmlListener.GetContext()
    $httpResponse = $httpContext.Response

    # return the HTML code/page to the caller
    $buffer = [Text.Encoding]::UTF8.GetBytes($html)
    $httpResponse.ContentLength64 = $buffer.length
    $httpResponse.OutputStream.Write($buffer, 0, $buffer.length)

    # close and stop http response and listener
    $httpResponse.Close()
}
$htmlListener.Stop()