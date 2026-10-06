$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search\probe"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$titles = @(
  "File:明-清 傳陳洪綬 青綠山水圖 軸-Landscape in the Blue-and-Green Manner MET DP67703.jpg",
  "File:Fairyland of Peach Blossoms - Qiu Ying.jpg",
  "File:Jade Cave Fairy Land - Qiu Ying.jpg",
  "File:Journey to Shu; Long.jpg",
  "File:Qiu Ying Peach Village.jpg",
  "File:Zhao Boju - Blue-Green Landscape - 20.311 - Rhode Island School of Design Museum.jpg"
)
$i = 0
foreach ($t in $titles) {
  $i++
  $enc = [uri]::EscapeDataString($t)
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&iiurlwidth=1000&titles=$enc"
  $out = Join-Path $tmp "q.json"
  curl.exe -s -A $ua -o $out $u
  try { $r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json } catch { Write-Output "$i PARSE-ERR"; continue }
  $page = $r.query.pages.PSObject.Properties | Select-Object -First 1
  $ii = $page.Value.imageinfo[0]
  if (-not $ii) { Write-Output "$i NO-INFO $t"; continue }
  $lic = $ii.extmetadata.LicenseShortName.value
  $thumb = $ii.thumburl
  $dest = Join-Path $tmp ("cand$i.jpg")
  curl.exe -s -A $ua -o $dest $thumb
  Write-Output ("$i  [" + $lic + "]  " + (Get-Item $dest).Length + " bytes  " + $t)
  Write-Output ("    " + $thumb)
  Start-Sleep -Seconds 2
}