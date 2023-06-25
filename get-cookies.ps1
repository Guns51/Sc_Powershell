if (-not (Get-Package 'Portable.BouncyCastle' -ErrorAction Ignore)) {
    if (-not (Get-PackageSource -Name NuGet -ErrorAction Ignore)) {
        Register-PackageSource -Name NuGet -Location https://api.nuget.org/v3/index.json -ProviderName NuGet | Set-PackageSource -Trusted
    }
    Install-Package -Name 'Portable.BouncyCastle' -Source NuGet -Scope CurrentUser -SkipDependencies
}
# Download the MySQLite repository (for PowerShell <5 without PowerShellGet)
if (-not(Get-Module -Name MySQLite -ErrorAction Ignore) -and ($PSVersionTable.PSVersion.Major -lt 5)) {
    $RepositoryZipUrl = 'https://api.github.com/repos/jdhitsolutions/MySQLite/zipball/master'
    Invoke-RestMethod -Uri $RepositoryZipUrl -OutFile 'MySQLite.zip'
    # Unblock the zip
    Unblock-File 'MySQLite.zip'
    # Extract the MySQLite folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)
    Expand-Archive -Path 'MySQLite.zip' -DestinationPath $($env:PSModulePath -split [System.IO.Path]::PathSeparator | Where-Object { (Test-Path -Path $_ -PathType Container -ErrorAction SilentlyContinue) -and $(try { $tmp = New-Item -Path $_ -Name ([System.IO.Path]::GetRandomFileName()) -ItemType File -Value (Get-Random) -ErrorAction SilentlyContinue; Remove-Item -Path $tmp; $true | Write-Output } catch { $false | Write-Output } ) } | Select-Object -First 1) -Force -Confirm
}
elseif (-not(Get-Module -Name MySQLite -ErrorAction Ignore) -and ($PSVersionTable.PSVersion.Major -ge 5))
{ #Simple alternative, if you have PowerShell ≥5, or the PowerShellGet module:
    Install-Module MySQLite -Repository PSGallery -Scope CurrentUser
}

# Import the MySQLite module
Import-Module MySQLite    #Alternatively, Import-Module \\Path\To\MySQLite
# Import Bouncy Castle Classes
Get-Package 'Portable.BouncyCastle' | ForEach-Object { Add-Type -LiteralPath ($_.Source | Split-Path | Get-ChildItem -Filter 'netstandard*' -Recurse -Directory | Get-ChildItem -Filter *.dll -Recurse -File ).FullName }
# Specify for which domain you want to retrieve cookies
$domain = 'mavaddat.ca'
$cookiesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies" # "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies" # "$env:APPDATA\Opera Software\Opera Stable\Cookies"

# Investigate the db structure
Get-MySQLiteTable -Path $cookiesPath -Detail

# Based on the schema of table `cookies`, form the query
$query = "SELECT name,encrypted_value,path,host_key FROM `"main`".`"cookies`" WHERE `"host_key`" LIKE '%$domain%' ESCAPE '\' LIMIT 0, 49999;"

# Or, get all cookies for all domains
$query = "SELECT name,encrypted_value,path,host_key FROM `"main`".`"cookies`" LIMIT 0, 49999;"

# Read the cookies from the SQLite
$cookies = Invoke-MySQLiteQuery -Path $cookiesPath -Query $query

# Get Chromium cookie master key
$localStatePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State" # "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State" # "$env:APPDATA\Opera Software\Opera Stable\Local State"
$cookiesKeyEncBaseSixtyFour = (Get-Content -Path $localStatePath | ConvertFrom-Json).'os_crypt'.'encrypted_key'
$cookiesKeyEnc = [System.Convert]::FromBase64String($cookiesKeyEncBaseSixtyFour) | Select-Object -Skip ([System.Text.Encoding]::UTF8.GetBytes('DPAPI').Count)
$cookiesKey = [System.Security.Cryptography.ProtectedData]::Unprotect($cookiesKeyEnc, $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)

# Prepare CSV file
$csvPath = "cookies.csv"
$csvContent = @()

# Prep the cipher elements
$cipher = [Org.BouncyCastle.Crypto.Modes.GcmBlockCipher]::new([Org.BouncyCastle.Crypto.Engines.AesEngine]::new())

# Stuff the cookies into the session
foreach ($cookie in $cookies) {
    $path = [string]::IsNullOrEmpty($cookie.path) ? '/' : $cookie.path
    $cipherStream = [System.IO.MemoryStream]::new($cookie.encrypted_value)
    $cipherReader = [System.IO.BinaryReader]::new($cipherStream)

    # Alternatively, if you don't care about 'v10', move the stream pointer past it
    $cipherReader.BaseStream.Position = [System.Text.Encoding]::ASCII.GetBytes('v10').Count

    $nonce = $cipherReader.ReadBytes([System.Security.Cryptography.AesGcm]::NonceByteSizes.MinSize)

    $parameters = [Org.BouncyCastle.Crypto.Parameters.AeadParameters]::new( ([Org.BouncyCastle.Crypto.Parameters.KeyParameter]::new($cookiesKey)), ([System.Security.Cryptography.AesGcm]::TagByteSizes.MaxSize * [byte]::MaxValue.GetShortestBitLength()), $nonce)
    $cipher.Init($false, $parameters)
    $cipherText = $cipherReader.ReadBytes($cookie.encrypted_value.Length)
    $plainText = [byte[]]::new($cipher.GetOutputSize($cipherText.Length))
    if (-not [string]::IsNullOrEmpty($plainText)) {
        try {
            $len = $cipher.ProcessBytes($cipherText, 0, $cipherText.Length, $plainText, 0)
            $bytesDeciphered = $cipher.DoFinal($plainText, $len)
            Write-Verbose "Deciphered $bytesDeciphered bytes"
        }
        catch [System.Management.Automation.MethodInvocationException] {
            # if inner exception [Org.BouncyCastle.Crypto.InvalidCipherTextException]
            if($_.Exception.InnerException -is [Org.BouncyCastle.Crypto.InvalidCipherTextException]) {
                Write-Error "Invalid Cipher Text"
            }
            else {
                Write-Error $_ # Echo the error unless you have a better way to handle
            }
            continue
        }
        finally {
            $cipher.Reset()
        }
        try{
            $cookieObj = [PSCustomObject]@{
                Domain = $cookie.host_key
                Name = $cookie.name
                Value = [System.Text.Encoding]::Default.GetString($plainText)
                Path = $path
            }
            $csvContent += $cookieObj
        } catch [System.Management.Automation.MethodInvocationException]{
            if($_.Exception.InnerException -is [System.Net.CookieException]) {
                $cookieObj = [PSCustomObject]@{
                    Domain = $cookie.host_key
                    Name = $cookie.name
                    Value = [System.Web.HttpUtility]::UrlEncode([System.Text.Encoding]::Default.GetString($plainText))
                    Path = $path
                }
                $csvContent += $cookieObj
            }
            else {
                Write-Error $_ # Echo the error unless you have a better way to handle
            }
        }
        $cipherStream.Close()
        $cipherStream.Dispose()
        $cipherReader.Close()
        $cipherReader.Dispose()
    }
}

# Export to CSV
$csvContent | Export-Csv -Path $csvPath -NoTypeInformation -Force

Write-Host "Cookies exported to $csvPath"
