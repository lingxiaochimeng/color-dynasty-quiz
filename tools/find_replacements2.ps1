$ErrorActionPreference = "Continue"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ColorDynastyQuiz/1.0"
$tmp = Join-Path $env:TEMP "cxc_search"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$groups = @(
  @{ slot = "color-11-shiqing"; qs = @("Zhao Boju landscape", "Autumn Colors on Rivers and Mountains", "blue and green landscape shanshui") },
  @{ slot = "dynasty-01-xia";   qs = @("Erlitou bronze", "Erlitou site Henan", "Erlitou turquoise") },
  @{ slot = "dynasty-02-shang"; qs = @("Houmuwu ding", "Simuwu ding", "Shang dynasty bronze ding museum") },
  @{ slot = "dynasty-07-sui";   qs = @("Sui dynasty porcelain", "Sui dynasty Buddha statue", "Sui dynasty museum") },
  @{ slot = "dynasty-11-ming";  qs = @("Ming dynasty blue and white porcelain vase", "Xuande blue and white", "Ming porcelain museum") },
  @{ slot = "dynasty-05-han";   qs = @("Han dynasty bronze museum", "Han dynasty jade burial suit", "Han dynasty tomb mural") }
)

foreach ($g in $groups) {
  Write-Output ("######## " + $g.slot)
  foreach ($q in $g.qs) {
    Write-Output ("  << " + $q)
    $enc = [uri]::EscapeDataString($q)
    $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=8&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&gsrsearch=$enc"
    $out = Join-Path $tmp "r.json"
    curl.exe -s -A $ua -o $out $u
    try {
      $r = Get-Content -Raw -Path $out -Encoding UTF8 | ConvertFrom-Json
    } catch { Write-Output "     PARSE-ERR"; Start-Sleep -Seconds 2; continue }
    $shown = 0
    if ($r.query.pages) {
      foreach ($p in $r.query.pages.PSObject.Properties) {
        $ii = $p.Value.imageinfo[0]
        if ($ii -and $ii.mime -like "image/*" -and $shown -lt 6) {
          $shown++
          $lic = $ii.extmetadata.LicenseShortName.value
          $free = "no"
          if ($lic -match "Public domain|CC0|PD-") { $free = "FREE" }
          Write-Output ("     [" + $free + "|" + $lic + "] " + $ii.width + "x" + $ii.height + "  " + $p.Value.title)
          Write-Output ("        " + ($ii.url -replace '\?.*$',''))
        }
      }
      if ($shown -eq 0) { Write-Output "     (none)" }
    } else { Write-Output "     (no result)" }
    Start-Sleep -Seconds 2
  }
}