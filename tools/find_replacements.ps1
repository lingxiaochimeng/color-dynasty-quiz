$ErrorActionPreference = "Continue"
$headers = @{ "User-Agent" = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)" }

$groups = @(
  @{ slot = "color-11-shiqing"; qs = @("Zhao Boju landscape painting", "blue green landscape Song dynasty", "Spring Excursion Zhan Ziqian") },
  @{ slot = "dynasty-01-xia";   qs = @("Erlitou bronze", "Erlitou site", "Erlitou turquoise dragon") },
  @{ slot = "dynasty-02-shang"; qs = @("Houmuwu ding", "Simuwu ding", "Shang dynasty bronze ding") },
  @{ slot = "dynasty-07-sui";   qs = @("Zhaozhou bridge", "Anji bridge Zhaozhou", "Sui dynasty white porcelain") },
  @{ slot = "dynasty-11-ming";  qs = @("Ming blue and white porcelain", "Xuande blue and white porcelain", "Ming dynasty porcelain vase") },
  @{ slot = "dynasty-05-han";   qs = @("Changxin Palace Lantern", "Flying Horse of Gansu", "Mawangdui silk banner Han") }
)

foreach ($g in $groups) {
  Write-Output ("######## " + $g.slot)
  foreach ($q in $g.qs) {
    Write-Output ("  << " + $q)
    $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=6&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&gsrsearch=" + [uri]::EscapeDataString($q)
    $ok = $false
    for ($try = 1; $try -le 4 -and -not $ok; $try++) {
      try {
        $r = Invoke-RestMethod -Uri $u -Headers $headers -TimeoutSec 40
        $ok = $true
        $shown = 0
        if ($r.query.pages) {
          foreach ($p in $r.query.pages.PSObject.Properties) {
            $ii = $p.Value.imageinfo[0]
            if ($ii.mime -like "image/*" -and $shown -lt 5) {
              $shown++
              $lic = $ii.extmetadata.LicenseShortName.value
              $free = "no"
              if ($lic -match "Public domain|CC0|PD-") { $free = "FREE" }
              Write-Output ("     [" + $free + "|" + $lic + "] " + $ii.width + "x" + $ii.height + "  " + $p.Value.title)
              Write-Output ("        " + ($ii.url -replace '\?.*$',''))
            }
          }
          if ($shown -eq 0) { Write-Output "     (none)" }
        }
        else { Write-Output "     (no result)" }
      }
      catch { if ($try -lt 4) { Start-Sleep -Seconds 8 } else { Write-Output ("     ERR " + $_.Exception.Message) } }
    }
    Start-Sleep -Seconds 3
  }
}