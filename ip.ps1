$test = Invoke-WebRequest -UseBasicParsing https://www.monippublique.com/

$test = $test.Content
$chaine1= '<h1>Votre IP publique est : <span class="big-green">'
$chaine2 = '</span></h1>'
$contenu = $test.IndexOf($chaine1)
$longueurdebut = $chaine1.Length
$in = $contenu + $longueurdebut
$contenu2 = $test.IndexOf($chaine2)
$result = $contenu2-$in
$f = $test.Substring($in,$result)
Write-Host "||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||"
Write-Host "Votre ip publique : " $f 
Write-Host "|||||||||||||||||||||||||||||||||||||||||||||||

|||||||||||||||||||||||||||||||||||||||||||||||"
pause
