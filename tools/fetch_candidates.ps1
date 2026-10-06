$ErrorActionPreference = "Continue"
$headers = @{ "User-Agent" = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)" }

$queries = @(
  @{ key = "C01-bai-snow";       q = "Chinese painting snow landscape winter Song dynasty" },
  @{ key = "C02-zhusha-red";     q = "Li Di red hibiscus painting" },
  @{ key = "C03-cihuang-yellow"; q = "Song dynasty painting yellow bird mulberry branch" },
  @{ key = "C04-mose-ink";       q = "Liang Kai Immortal in Splashed Ink" },
  @{ key = "C05-zheshi-ochre";   q = "Fan Kuan Travelers Among Mountains and Streams" },
  @{ key = "C06-yanzhi-rouge";   q = "Zhou Fang court ladies adorning hair flowers" },
  @{ key = "C07-zhubiao-orange"; q = "Herd of Deer in a Maple Grove Liao" },
  @{ key = "C08-tenghuang";      q = "Huang Quan Sketches of Birds and Insects" },
  @{ key = "C09-huaqing";        q = "Wang Meng Dwelling in the Qingbian Mountains" },
  @{ key = "C10-shilv-green";    q = "Wang Ximeng Thousand Li of Rivers and Mountains" },
  @{ key = "C11-shiqing-blue";   q = "Zhan Ziqian Spring Excursion" },
  @{ key = "C12-yanghong-rose";  q = "Yun Shouping flower painting Qing" },
  @{ key = "D01-xia-erlitou";    q = "Erlitou bronze jue" },
  @{ key = "D02-shang-ding";     q = "Houmuwu ding Simuwu bronze" },
  @{ key = "D03-zhou-hezun";     q = "He zun bronze vessel" },
  @{ key = "D04-qin-terracotta"; q = "Terracotta Army warriors pit" },
  @{ key = "D05-han-lantern";    q = "Changxin Palace Lantern gilt bronze" },
  @{ key = "D06-weijin-luoshen"; q = "Nymph of the Luo River Gu Kaizhi" },
  @{ key = "D07-sui-bridge";     q = "Anji Bridge Zhaozhou" },
  @{ key = "D08-tang-bunian";    q = "Emperor Taizong Receiving the Tibetan Envoy" },
  @{ key = "D09-song-qingming";  q = "Along the River During the Qingming Festival" },
  @{ key = "D10-yuan-fuchun";    q = "Dwelling in the Fuchun Mountains Huang Gongwang" },
  @{ key = "D11-ming-bluewhite"; q = "Ming dynasty blue and white porcelain vase" },
  @{ key = "D12-qing-horses";    q = "Lang Shining Hundred Horses" }
)

foreach ($item in $queries) {
  $u = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=6&prop=imageinfo&iiprop=url%7Csize%7Cmime%7Cextmetadata&gsrsearch=" + [uri]::EscapeDataString($item.q)
  Write-Output ("=== " + $item.key + "  << " + $item.q)
  $ok = $false
  for ($try = 1; $try -le 3 -and -not $ok; $try++) {
    try {
      $r = Invoke-RestMethod -Uri $u -Headers $headers -TimeoutSec 40
      $ok = $true
      $shown = 0
      if ($r.query.pages) {
        foreach ($p in $r.query.pages.PSObject.Properties) {
          $pg = $p.Value
          $ii = $pg.imageinfo[0]
          if ($ii.mime -like "image/*" -and $shown -lt 3) {
            $shown++
            $lic = $ii.extmetadata.LicenseShortName.value
            $artist = $ii.extmetadata.Artist.value -replace '<[^>]+>',''
            if ($artist.Length -gt 40) { $artist = $artist.Substring(0,40) }
            Write-Output ("  [" + $ii.width + "x" + $ii.height + "] " + $pg.title)
            Write-Output ("      lic=" + $lic + " | by=" + $artist)
            Write-Output ("      " + ($ii.url -replace '\?.*$',''))
          }
        }
        if ($shown -eq 0) { Write-Output "  (no image result)" }
      }
      else { Write-Output "  (no result)" }
    }
    catch {
      if ($try -lt 3) { Start-Sleep -Seconds 6 }
      else { Write-Output ("  ERR " + $_.Exception.Message) }
    }
  }
  Start-Sleep -Seconds 3
}