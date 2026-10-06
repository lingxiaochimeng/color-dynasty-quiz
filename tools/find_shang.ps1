$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# 1) retry the failed search
$queries = @("Houmuwu Ding National Museum of China", "Houmuwu ding bronze", "Simuwu Ding")
foreach ($q in $queries) {
  Write-Output ("<< " + $q)
  $enc = [uri]::EscapeDataString($q)
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=10&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&gsrsearch=$enc"
  $out = Join-Path $tmp "s.json"
  curl.exe -s -A $ua -o $out $u
  try { $r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json } catch { Write-Output "  PARSE-ERR"; Start-Sleep -Seconds 3; continue }
  $shown = 0
  if ($r.query.pages) {
    foreach ($p in $r.query.pages.PSObject.Properties) {
      $ii = $p.Value.imageinfo[0]
      if ($ii -and $ii.mime -like "image/*" -and $shown -lt 8) {
        $shown++
        $lic = $ii.extmetadata.LicenseShortName.value
        $free = "no"; if ($lic -match "Public domain|CC0|PD-") { $free = "FREE" }
        Write-Output ("  [" + $free + "|" + $lic + "] " + $ii.width + "x" + $ii.height + "  " + $p.Value.title)
        Write-Output ("     " + ($ii.url -replace '\?.*$',''))
      }
    }
  }
  Start-Sleep -Seconds 3
}