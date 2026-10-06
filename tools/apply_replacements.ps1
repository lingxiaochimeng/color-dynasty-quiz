$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$imgDir = "d:\trae\try1\images"

$items = @(
  @{ slot = "color-11-shiqing"; ext = "jpg"; title = "File:Autumn Colors on Rivers and Mountains, Northern Song Dynasty.jpg" },
  @{ slot = "dynasty-01-xia";   ext = "jpg"; title = "File:Turquoise-Inlaid Plaque with Stylized Animal-Mask Decoration and Elongated Extension, 1900-1350 BC, Neolithic to Shang period, Erlitou culture, China, bronze with turquoise inlay - Sackler Museum - DSC02630.JPG" },
  @{ slot = "dynasty-02-shang"; ext = "jpg"; title = 'File:Shang Bronze "Hou Mu Wu" Ding, Largest Ever Found (10197814663).jpg' },
  @{ slot = "dynasty-05-han";   ext = "jpg"; title = "File:2nd Cent. BC to 2nd Cent. AD Han Dynasty Bronze Horse.jpg" },
  @{ slot = "dynasty-07-sui";   ext = "jpg"; title = "File:Sui Dynasty Blue Glazed Pottery Equestrian.jpg" },
  @{ slot = "dynasty-11-ming";  ext = "jpg"; title = "File:Ming Porcelain Vase 01.jpg" }
)

$results = @()
foreach ($it in $items) {
  Write-Output ("#### " + $it.slot)
  $enc = [uri]::EscapeDataString($it.title)
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&iiurlwidth=1920&titles=$enc"
  $out = Join-Path $tmp "m.json"
  curl.exe -s -A $ua -o $out $u
  try { $r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json } catch { Write-Output "  PARSE-ERR"; continue }
  $page = $r.query.pages.PSObject.Properties | Select-Object -First 1
  if (-not $page) { Write-Output "  NO-PAGE"; continue }
  $ii = $page.Value.imageinfo[0]
  if (-not $ii) { Write-Output "  NO-INFO"; continue }
  $em = $ii.extmetadata
  $artist = $em.Artist.value
  if ($artist) { $artist = ($artist -replace '<[^>]+>','').Trim() }
  $lic = $em.LicenseShortName.value
  $licUrl = $em.LicenseUrl.value
  $thumb = $ii.thumburl
  $dest = Join-Path $imgDir ($it.slot + "." + $it.ext)
  curl.exe -s -A $ua -o $dest $thumb
  $len = (Get-Item $dest).Length
  Write-Output ("  saved " + $dest + "  " + $len + " bytes  [" + $lic + "]  by " + $artist)
  $results += [pscustomobject]@{
    file = ($it.slot + "." + $it.ext)
    work = $page.Value.title -replace '^File:','' -replace '\.(jpg|JPG|png|PNG)$',''
    author = $artist
    license = $lic
    licenseUrl = $licUrl
    source = ($thumb -replace '\?.*$','')
  }
  Start-Sleep -Seconds 3
}
$results | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $tmp "replacements.json") -Encoding UTF8
Write-Output "----DONE----"