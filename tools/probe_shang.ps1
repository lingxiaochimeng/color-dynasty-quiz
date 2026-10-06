$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search\probe"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$titles = @(
  'File:Bronze "Hou Mu Wu" ding closeup.jpg',
  'File:Late Shang bronze "Hou Mu Wu" ding (9835235495).jpg',
  'File:Late Shang bronze "Hou Mu Wu" ding (9836361235).jpg'
)
$i = 10
foreach ($t in $titles) {
  $i++
  $enc = [uri]::EscapeDataString($t)
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&iiurlwidth=1000&titles=$enc"
  $out = Join-Path $tmp "q.json"
  curl.exe -s -A $ua -o $out $u
  try { $r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json } catch { Write-Output "$i PARSE-ERR"; continue }
  $page = $r.query.pages.PSObject.Properties | Select-Object -First 1
  $ii = $page.Value.imageinfo[0]
  if (-not $ii) { Write-Output "$i NO-INFO"; continue }
  $dest = Join-Path $tmp ("cand$i.jpg")
  curl.exe -s -A $ua -o $dest $ii.thumburl
  Write-Output ("$i  [" + $ii.extmetadata.LicenseShortName.value + "]  " + $ii.width + "x" + $ii.height + "  -> " + $dest)
  Start-Sleep -Seconds 2
}