$ErrorActionPreference = "Continue"
$headers = @{ "User-Agent" = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)" }

$queries = @(
  @{ key = "C01a-xuexi";   q = "Wang Wei Snow Creek painting" },
  @{ key = "C01b-jiufeng"; q = "Nine Peaks after Snow Huang Gongwang" },
  @{ key = "C01c-snow";    q = "Chinese landscape painting snow winter mountain" },
  @{ key = "D09-zhangzeduan"; q = "Zhang Zeduan Along the River During the Qingming Festival" },
  @{ key = "D03a-hezun";   q = "He zun bronze" },
  @{ key = "D03b-maogong"; q = "Mao Gong ding bronze vessel" }
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