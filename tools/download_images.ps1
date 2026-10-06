$ErrorActionPreference = "Continue"
$ua = "ColorDynastyQuiz/1.0 (educational demo; contact: local-user)"
$outDir = "d:\trae\try1\images"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
Get-ChildItem $outDir -File | Where-Object { $_.Length -lt 5000 } | Remove-Item -Force

$items = @(
  @{ n="color-01-bai";       t="File:Angler on a Wintry Lake, by Ma Yuan, 1195.jpg"; by="Ma Yuan"; lic="Public domain"; w="Angler on a Wintry Lake" },
  @{ n="color-02-zhusha";    t="File:Li Di - Red and White Cotton Roses - Google Art Project.jpg"; by="Li Di"; lic="Public domain"; w="Red and White Cotton Roses" },
  @{ n="color-03-cihuang";   t=$null; fb='https://upload.wikimedia.org/wikipedia/commons/d/da/%E6%A1%91%E6%9E%9D%E9%BB%83%E9%B3%A5.jpg'; by="Unknown (Song)"; lic="Public domain"; w="Mulberry Branch and Yellow Bird" },
  @{ n="color-04-mose";      t="File:Liang Kai - Immortal in Splashed Ink.jpg"; by="Liang Kai"; lic="Public domain"; w="Immortal in Splashed Ink" },
  @{ n="color-05-zheshi";    t="File:Fan Kuan - Travelers Among Mountains and Streams - Google Art Project.jpg"; by="Fan Kuan"; lic="Public domain"; w="Travelers Among Mountains and Streams" },
  @{ n="color-06-yanzhi";    t="File:Zhou Fang. Court Ladies Wearing Flowered Headdresses.Detail1.jpg"; by="Zhou Fang"; lic="Public domain"; w="Court Ladies Wearing Flowered Headdresses (detail)" },
  @{ n="color-07-zhubiao";   t="File:Herd of Deer in a Maple Grove.png"; by="Unknown (Liao)"; lic="Public domain"; w="Herd of Deer in a Maple Grove" },
  @{ n="color-08-tenghuang"; t="File:Huang-Quan-Xie-sheng-zhen-qin-tu.jpg"; by="Huang Quan"; lic="Public domain"; w="Sketches of Birds and Insects" },
  @{ n="color-09-huaqing";   t="File:Wang Meng Dwelling in the Qingbian Mountains. ink on paper. 1366. 141x42,2 cm. Shanghai Museum.jpg"; by="Wang Meng"; lic="Public domain"; w="Dwelling in the Qingbian Mountains" },
  @{ n="color-10-shilv";     t="File:1c Wang Ximeng. A Thousand Li of Rivers and Mountains. (51,3x1191,5cm)1113. (section) Palace museum, Beijing.jpg"; by="Wang Ximeng"; lic="Public domain"; w="A Thousand Li of Rivers and Mountains (section)" },
  @{ n="color-11-shiqing";   t="File:Spring Excursion.png"; by="Zhan Ziqian"; lic="CC BY-SA 4.0"; w="Spring Excursion" },
  @{ n="color-12-yanghong";  t="File:Peonies, Yun Shouping.jpg"; by="Yun Shouping"; lic="Public domain"; w="Peonies" },
  @{ n="dynasty-01-xia";     t="File:20251026 Bronze Jue from Erlitou.jpg"; by="Windmemories"; lic="CC BY-SA 4.0"; w="Bronze Jue from Erlitou" },
  @{ n="dynasty-02-shang";   t="File:HouMuWuDingFullView.jpg"; by="Mlogic"; lic="CC BY-SA 3.0"; w="Houmuwu Ding (Simuwu Ding)" },
  @{ n="dynasty-03-zhou";    t="File:Western Zhou Bronze Zun (National Treasure) (9925581905).jpg"; by="Gary Todd"; lic="CC0"; w="Western Zhou Bronze Zun (He Zun)" },
  @{ n="dynasty-04-qin";     t="File:Qin Terracotta Warriors, Pit 1 01.jpg"; by="Gary Todd"; lic="CC0"; w="Terracotta Warriors, Pit 1" },
  @{ n="dynasty-05-han";     t="File:ChangXingongdeng.jpg"; by="Refrain (zh.wikipedia)"; lic="CC BY 1.0"; w="Changxin Palace Lantern" },
  @{ n="dynasty-06-weijin";  t="File:B Gu Kaizhi. Nymph of the Luo River. (section) Southern Song Copy. Liaoning Provincial museum.jpg"; by="Gu Kaizhi (copy)"; lic="Public domain"; w="Nymph of the Luo River (section)" },
  @{ n="dynasty-07-sui";     t="File:Anji Bridge, Zhao County, 2020-09-06 02.jpg"; by="Siyuwj"; lic="CC BY-SA 4.0"; w="Anji Bridge (Zhaozhou Bridge)" },
  @{ n="dynasty-08-tang";    t="File:Emperor Taizong gives an audience to the ambassador of Tibet.jpg"; by="Yan Liben"; lic="Public domain"; w="Emperor Taizong Receiving the Tibetan Envoy" },
  @{ n="dynasty-09-song";    t="File:Along the River During the Qingming Festival (detail of original).jpg"; by="Zhang Zeduan"; lic="Public domain"; w="Along the River During the Qingming Festival (detail)" },
  @{ n="dynasty-10-yuan";    t="File:Huang Gongwang. Dwelling in the Fuchun Mountains. detail. National Palace Museum, Taipei.jpg"; by="Huang Gongwang"; lic="Public domain"; w="Dwelling in the Fuchun Mountains (detail)" },
  @{ n="dynasty-11-ming";    t="File:20241025 Blue and White Porcelain Vase with Interlocking Lotus Design of Wanli Reign, Ming Dynasty.jpg"; by="Windmemories"; lic="CC BY-SA 4.0"; w="Blue and White Porcelain Vase (Ming)" },
  @{ n="dynasty-12-qing";    t="File:One Hundred Horses (part1).jpg"; by="Giuseppe Castiglione (Lang Shining)"; lic="Public domain"; w="One Hundred Horses (part)" }
)

# ---- fetch official thumburls in one batch ----
$map = @{}
$titles = ($items | Where-Object { $_.t } | ForEach-Object { $_.t }) -join "|"
$api = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&iiurlwidth=1400&titles=" + [uri]::EscapeDataString($titles)
$ok = $false
for ($try = 1; $try -le 4 -and -not $ok; $try++) {
  try {
    $r = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = $ua } -TimeoutSec 60
    $ok = $true
    foreach ($p in $r.query.pages.PSObject.Properties) {
      $ii = $p.Value.imageinfo[0]
      $map[$p.Value.title] = ($ii.thumburl -replace '\?.*$','')
    }
  }
  catch { if ($try -lt 4) { Start-Sleep -Seconds 6 } else { Write-Output ("API ERR " + $_.Exception.Message) } }
}
Write-Output ("thumburls resolved: " + $map.Count)

# ---- download ----
$credits = @()
foreach ($it in $items) {
  $ext = ".jpg"; if ($it.t -and $it.t.ToLower().EndsWith(".png")) { $ext = ".png" }
  $url = $null
  if ($it.t -and $map.ContainsKey($it.t)) { $url = $map[$it.t] }
  elseif ($it.fb) { $url = $it.fb }
  if (-not $url) { Write-Output ("SKIP " + $it.n + " (no url)"); continue }
  $dest = Join-Path $outDir ($it.n + $ext)
  $okd = $false
  for ($try = 1; $try -le 3 -and -not $okd; $try++) {
    & curl.exe -sS -L -A $ua --max-time 180 -o $dest $url 2>$null
    if ($LASTEXITCODE -eq 0 -and (Test-Path $dest) -and (Get-Item $dest).Length -gt 5000) {
      $okd = $true
      Write-Output ("OK   " + $it.n + $ext + "   " + [math]::Round((Get-Item $dest).Length/1KB) + " KB")
    }
    elseif ($try -lt 3) { Start-Sleep -Seconds 5 }
    else { Write-Output ("FAIL " + $it.n + "  curl=" + $LASTEXITCODE) }
  }
  $credits += [pscustomobject]@{ file = $it.n + $ext; work = $it.w; author = $it.by; license = $it.lic; source = $url }
}
$credits | ConvertTo-Json -Depth 4 | Out-File -FilePath (Join-Path $outDir "credits.json") -Encoding utf8
Write-Output "---- done ----"