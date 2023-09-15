# Send an HTTP GET request and save the content to a variable
$url = "http://challenge01.root-me.org/programmation/ch1/"
$content = wget -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content

# Use regular expressions to extract numeric values
$matches = [System.Text.RegularExpressions.Regex]::Matches($content, '\d+')

$U = [int]$matches[5].Value
$premier = [int]$matches[1].Value
$deuxieme = [int]$matches[2].Value
$U0 = [int]$matches[4].Value

# Define a function to calculate the sequence term
function Calculate-SequenceTerm($n) {
    $U0 = @()  # Initialize the sequence with an empty array
    $U0 += 8   # Add the initial term U0 to the array
    for ($i = 1; $i -le $n; $i++) {
        $term = ($premier + $U0[$i - 1]) + ($i * $deuxieme)
        $U0 += $term
    }
    return $U0[$n]
}

$term_309129 = Calculate-SequenceTerm $U
Write-Host "U309129 =" $term_309129
