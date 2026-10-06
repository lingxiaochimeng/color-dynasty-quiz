$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$title = "File:Journey to Shu; Long.jpg"
$enc = [uri]::EscapeDataString($title)
$u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&iiurlwidth=1920&titles=$enc"
$out = Join-Path $tmp "js.json"
curl.exe -s -A $ua -o $out $u
$r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json
$page = $r.query.pages.PSObject.Properties | Select-Object -First 1
$ii = $page.Value.imageinfo[0]
$em = $ii.extmetadata
Write-Output ("TITLE   : " + $page.Value.title)
Write-Output ("SIZE    : " + $ii.width + "x" + $ii.height)
Write-Output ("LICENSE : " + $em.LicenseShortName.value)
Write-Output ("LICURL  : " + $em.LicenseUrl.value)
Write-Output ("ARTIST  : " + (($em.Artist.value -replace '<[^>]+>','').Trim()))
Write-Output ("DESC    : " + (($em.ImageDescription.value -replace '<[^>]+>','').Trim()))
Write-Output ("DATE    : " + (($em.DateTimeOriginal.value -replace '<[^>]+>','').Trim()))
Write-Output ("THUMB   : " + $ii.thumburl)
$dest = "d:\trae\try1\images\color-11-shiqing.jpg"
curl.exe -s -A $ua -o $dest $ii.thumburl
Write-Output ("SAVED   : " + (Get-Item $dest).Length + " bytes")