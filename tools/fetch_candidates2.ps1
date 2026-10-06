$ErrorActionPreference = "Continue"
$headers = @{ "User-Agent" = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)" }

$queries = @(
  @{ key = "C01a-snow-fankuan"; q = "Snow Landscape Fan Kuan" },
  @{ key = "C01b-snow-generic"; q = "Chinese painting snow mountains winter" },
  @{ key = "C06a-zanhua";       q = "Court Ladies Wearing Flowered Headdresses Zhou Fang" },
  @{ key = "C06b-daolian";      q = "Court Ladies Preparing Newly Woven Silk" },
  @{ key = "C11-youchun";       q = "Zhan Ziqian Spring Excursion" },
  @{ key = "D10-fuchun";        q = "Dwelling in the Fuchun Mountains" },
  @{ key = "D12a-hundred";      q = "Hundred Horses Castiglione" },
  @{ key = "D12b-lang";         q = "Giuseppe Castiglione painting horse Qing" }
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
  Start-Sleep -Seconds 5
}