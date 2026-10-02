Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\SEO STZK\.gemini\antigravity-ide\brain\3e5938ec-8277-4f01-8709-b0abd439f06a\playstore_feature_graphic_1790947550872.jpg"
$destDir = "d:\allgujaratvankarsamaj\playstore_assets"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
}

$srcImg = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "Source dimensions: $($srcImg.Width) x $($srcImg.Height)"

$targetWidth = 1024
$targetHeight = 512
$targetRatio = $targetWidth / $targetHeight
$srcRatio = $srcImg.Width / $srcImg.Height

if ($srcRatio -gt $targetRatio) {
    $cropHeight = $srcImg.Height
    $cropWidth = [int]($srcImg.Height * $targetRatio)
    $cropX = [int](($srcImg.Width - $cropWidth) / 2)
    $cropY = 0
} else {
    $cropWidth = $srcImg.Width
    $cropHeight = [int]($srcImg.Width / $targetRatio)
    $cropX = 0
    $cropY = [int](($srcImg.Height - $cropHeight) / 2)
}

$destBmp = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
$g = [System.Drawing.Graphics]::FromImage($destBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

$destRect = New-Object System.Drawing.Rectangle(0, 0, $targetWidth, $targetHeight)
$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropWidth, $cropHeight)

$g.DrawImage($srcImg, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$srcImg.Dispose()

$pngPath = Join-Path $destDir "feature_graphic_1024x512.png"
$jpgPath = Join-Path $destDir "feature_graphic_1024x512.jpg"

$destBmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
$destBmp.Save($jpgPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$destBmp.Dispose()

Write-Host "Saved: $pngPath and $jpgPath"

$verify = [System.Drawing.Image]::FromFile($pngPath)
Write-Host "Verified Output: $($verify.Width) x $($verify.Height)"
$verify.Dispose()
