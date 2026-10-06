$ErrorActionPreference = "Continue"
$headers = @{ "User-Agent" = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)" }

$queries = @(
  @{ key = "C01a-mayuan"; q = "Ma Yuan Angler on a Wintry Lake" },
  @{ key = "C01b-libai";  q = "Liang Kai Li Bai Strolling" },
  @{ key = "C01c-songxue"; q = "Song dynasty snow landscape painting" }
)

foreach ($item in $queries) {
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=6&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&gsrsearch=" + [uri]::EscapeDataString($item.q)
  Write-Output ("=== " + $item.key + "  << " + $item.q)
  $ok = $false
  for ($try = 1; $try -le 4 -and -not $ok; $try++) {
    try {
      $r = Invoke-RestMethod -Uri $u -Headers $headers -TimeoutSec 40
      $ok = $true
      $shown = 0
      if ($r.query.pages) {
        foreach ($p in $r.query.pages.PSObject.Properties) {
          $pg = $p.Value
          $ii = $pg.imageinfo[0]
          if ($ii.mime -like "image/*" -and $shown -lt 4) {
            $shown++
            $lic = $ii.extmetadata.LicenseShortName.value
            Write-Output ("  [" + $ii.width + "x" + $ii.height + "] " + $pg.title + "   lic=" + $lic)
            Write-Output ("      " + ($ii.url -replace '\?.*$',''))
          }
        }
        if ($shown -eq 0) { Write-Output "  (no image result)" }
      }
      else { Write-Output "  (no result)" }
    }
    catch {
      if ($try -lt 4) { Start-Sleep -Seconds 8 }
      else { Write-Output ("  ERR " + $_.Exception.Message) }
    }
  }
  Start-Sleep -Seconds 4
}

# verify the Western Zhou zun image description
Write-Output "=== VERIFY-zun"
try {
  $t = "File:Western Zhou Bronze Zun (National Treasure) (9925581905).jpg"
  $v = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=extmetadata&titles=" + [uri]::EscapeDataString($t)
  $r2 = Invoke-RestMethod -Uri $v -Headers $headers -TimeoutSec 40
  foreach ($p in $r2.query.pages.PSObject.Properties) {
    $d = $p.Value.imageinfo[0].extmetadata.ImageDescription.value
    $d = $d -replace '<[^>]+>',' '
    if ($d.Length -gt 300) { $d = $d.Substring(0,300) }
    Write-Output ("  desc: " + $d)
  }
}
catch { Write-Output ("  ERR " + $_.Exception.Message) }