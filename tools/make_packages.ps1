$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root   = "d:\trae\try1"
$srcDir = Join-Path $root "images"
$tmp    = Join-Path $env:TEMP "cdq_build"
$utf8   = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# ---------- 1) full source package ----------
$full = Join-Path $tmp "color-dynasty-quiz"
New-Item -ItemType Directory -Force -Path $full | Out-Null
foreach ($f in @("index.html", "mapping-table.html", "question-bank.html", "image-preview.html", "README.md", "LICENSE")) {
  Copy-Item (Join-Path $root $f) -Destination $full
}
Copy-Item $srcDir -Destination $full -Recurse
Copy-Item (Join-Path $root "tools") -Destination $full -Recurse
$z1 = Join-Path $root "color-dynasty-quiz.zip"
if (Test-Path $z1) { Remove-Item $z1 -Force }
tar.exe -a -c -f $z1 -C $tmp "color-dynasty-quiz"

# ---------- 2) site package (original image quality) ----------
$site = Join-Path $tmp "site"
New-Item -ItemType Directory -Force -Path $site | Out-Null
Copy-Item (Join-Path $root "index.html") -Destination $site
Copy-Item $srcDir -Destination $site -Recurse
$z2 = Join-Path $root "color-dynasty-quiz-site.zip"
if (Test-Path $z2) { Remove-Item $z2 -Force }
tar.exe -a -c -f $z2 -C $site index.html images

# ---------- 3) mini site package (compressed images) ----------
$mini = Join-Path $tmp "mini"
New-Item -ItemType Directory -Force -Path (Join-Path $mini "images") | Out-Null

# the PNG that becomes JPG -> patch its references
$idx = [System.IO.File]::ReadAllText((Join-Path $root "index.html"))
$idx = $idx -replace 'images/color-07-zhubiao\.png', 'images/color-07-zhubiao.jpg'
[System.IO.File]::WriteAllText((Join-Path $mini "index.html"), $idx, $utf8)

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
if (-not $codec) { throw "JPEG encoder not found" }
$ep = New-Object -TypeName System.Drawing.Imaging.EncoderParameters -ArgumentList 1
$ep.Param[0] = New-Object -TypeName System.Drawing.Imaging.EncoderParameter -ArgumentList ([System.Drawing.Imaging.Encoder]::Quality, 85L)

$before = 0
$after  = 0
Get-ChildItem $srcDir -File | Where-Object { $_.Extension -match '^\.(jpg|jpeg|png)$' } | ForEach-Object {
  $before += $_.Length
  $img = [System.Drawing.Image]::FromFile($_.FullName)
  $w = $img.Width
  $h = $img.Height
  $scale = [math]::Min(1.0, [math]::Min(1600 / $w, 1600 / $h))
  $nw = [int][math]::Max(1, [math]::Round($w * $scale))
  $nh = [int][math]::Max(1, [math]::Round($h * $scale))
  $bmp = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $nw, $nh
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.DrawImage($img, 0, 0, $nw, $nh)
  $g.Dispose()
  $out = Join-Path (Join-Path $mini "images") ([System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ".jpg")
  $bmp.Save($out, $codec, $ep)
  $bmp.Dispose()
  $img.Dispose()
  $after += (Get-Item $out).Length
}
$ep.Dispose()

$cj = [System.IO.File]::ReadAllText((Join-Path $srcDir "credits.json"))
$cj = $cj -replace 'color-07-zhubiao\.png', 'color-07-zhubiao.jpg'
[System.IO.File]::WriteAllText((Join-Path $mini "images\credits.json"), $cj, $utf8)

$z3 = Join-Path $root "color-dynasty-quiz-site-mini.zip"
if (Test-Path $z3) { Remove-Item $z3 -Force }
tar.exe -a -c -f $z3 -C $mini index.html images

Remove-Item $tmp -Recurse -Force

Write-Output ("full : " + [math]::Round((Get-Item $z1).Length / 1MB, 2) + " MB")
Write-Output ("site : " + [math]::Round((Get-Item $z2).Length / 1MB, 2) + " MB")
Write-Output ("mini : " + [math]::Round((Get-Item $z3).Length / 1MB, 2) + " MB   (images " + [math]::Round($before / 1MB, 2) + " -> " + [math]::Round($after / 1MB, 2) + " MB)")