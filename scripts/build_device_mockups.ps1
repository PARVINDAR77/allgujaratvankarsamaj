Add-Type -AssemblyName System.Drawing

$baseDir = "D:\allgujaratvankarsamaj"
$assetsDir = Join-Path $baseDir "application\assets\images"
$outBase = Join-Path $baseDir "playstore_assets"
$jsonFile = Join-Path $baseDir "scripts\slides.json"

$phoneDir = Join-Path $outBase "phone_1080x2400"
$tab7Dir = Join-Path $outBase "tablet_7inch_1200x1920"
$tab10Dir = Join-Path $outBase "tablet_10inch_ipad_1600x2560"
$laptopDir = Join-Path $outBase "laptop_1920x1080"

$dirs = @($phoneDir, $tab7Dir, $tab10Dir, $laptopDir)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
}

$rawJson = [System.IO.File]::ReadAllText($jsonFile, [System.Text.Encoding]::UTF8)
$slides = ConvertFrom-Json $rawJson

function Generate-Device-Slide($CanvasWidth, $CanvasHeight, $Slide, $DeviceType, $OutFile) {
    $bmp = New-Object System.Drawing.Bitmap($CanvasWidth, $CanvasHeight)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. Royal Navy gradient background
    $rect = New-Object System.Drawing.Rectangle(0, 0, $CanvasWidth, $CanvasHeight)
    $cTop = [System.Drawing.Color]::FromArgb(4, 16, 38)
    $cBottom = [System.Drawing.Color]::FromArgb(10, 28, 65)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cTop, $cBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # Golden border
    $goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 212, 175, 55), 3)
    $g.DrawRectangle($goldPen, 24, 24, $CanvasWidth - 48, $CanvasHeight - 48)
    $goldPen.Dispose()

    # Geometry
    if ($DeviceType -eq "Laptop") {
        $headerY = [int]($CanvasHeight * 0.06)
        $frameW = [int]($CanvasWidth * 0.72)
        $frameH = [int]($CanvasHeight * 0.62)
        $frameX = [int](($CanvasWidth - $frameW) / 2)
        $frameY = [int]($CanvasHeight * 0.30)
    } else {
        $headerY = [int]($CanvasHeight * 0.04)
        $frameW = [int]($CanvasWidth * 0.82)
        $frameH = [int]($CanvasHeight * 0.73)
        $frameX = [int](($CanvasWidth - $frameW) / 2)
        $frameY = [int]($CanvasHeight * 0.22)
    }

    # 2. Typography
    $goldColor = [System.Drawing.Color]::FromArgb(212, 175, 55)
    $goldBrush = New-Object System.Drawing.SolidBrush($goldColor)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $tagBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 212, 175, 55))

    # Pill Tag
    $tagFontSize = [float]($CanvasWidth * 0.022)
    $tagFont = New-Object System.Drawing.Font("Arial", $tagFontSize, [System.Drawing.FontStyle]::Bold)
    $tagText = $Slide.Tag
    $tagSize = $g.MeasureString($tagText, $tagFont)
    $tagPadX = 24
    $tagPadY = 10
    $tagRect = New-Object System.Drawing.RectangleF(($CanvasWidth - $tagSize.Width - $tagPadX) / 2, $headerY, $tagSize.Width + $tagPadX, $tagSize.Height + $tagPadY)
    $g.FillRectangle($tagBgBrush, $tagRect)
    $tagPen = New-Object System.Drawing.Pen($goldColor, 1.5)
    $g.DrawRectangle($tagPen, $tagRect.X, $tagRect.Y, $tagRect.Width, $tagRect.Height)
    $tagPen.Dispose()
    $g.DrawString($tagText, $tagFont, $goldBrush, ($CanvasWidth - $tagSize.Width) / 2, $headerY + ($tagPadY / 2))
    $tagFont.Dispose()

    # Main Headline
    $headFontSize = [float]($CanvasWidth * 0.044)
    $headFont = New-Object System.Drawing.Font("Arial", $headFontSize, [System.Drawing.FontStyle]::Bold)
    $headText = $Slide.Headline
    $headSize = $g.MeasureString($headText, $headFont)
    $headY = $headerY + $tagSize.Height + $tagPadY + 16
    $g.DrawString($headText, $headFont, $whiteBrush, ($CanvasWidth - $headSize.Width) / 2, $headY)
    $headFont.Dispose()

    # Gujarati Subtitle (using Nirmala UI)
    $gujFontSize = [float]($CanvasWidth * 0.030)
    $gujFont = New-Object System.Drawing.Font("Nirmala UI", $gujFontSize, [System.Drawing.FontStyle]::Bold)
    $gujText = $Slide.Gujarati
    $gujSize = $g.MeasureString($gujText, $gujFont)
    $gujY = $headY + $headSize.Height + 10
    $g.DrawString($gujText, $gujFont, $goldBrush, ($CanvasWidth - $gujSize.Width) / 2, $gujY)
    $gujFont.Dispose()

    # 3. Device Bezel
    $bezelPad = 12
    $bezelRect = New-Object System.Drawing.Rectangle($frameX - $bezelPad, $frameY - $bezelPad, $frameW + ($bezelPad * 2), $frameH + ($bezelPad * 2))
    
    # Drop shadow
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
    $g.FillRectangle($shadowBrush, $bezelRect.X + 8, $bezelRect.Y + 12, $bezelRect.Width, $bezelRect.Height)
    $shadowBrush.Dispose()

    # Bezel body
    $bezelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 24, 32))
    $g.FillRectangle($bezelBrush, $bezelRect)
    $bezelBrush.Dispose()

    # Golden rim
    $rimPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 212, 175, 55), 2)
    $g.DrawRectangle($rimPen, $bezelRect)
    $rimPen.Dispose()

    # 4. Screen Image
    $screenRect = New-Object System.Drawing.Rectangle($frameX, $frameY, $frameW, $frameH)
    $assetFile = Join-Path $assetsDir $Slide.Asset
    if (-not (Test-Path $assetFile)) {
        $assetFile = Join-Path $assetsDir $Slide.Fallback
    }

    if (Test-Path $assetFile) {
        $sImg = [System.Drawing.Image]::FromFile($assetFile)
        $screenAspect = $frameW / $frameH
        $imgAspect = $sImg.Width / $sImg.Height

        if ($imgAspect -gt $screenAspect) {
            $srcH = $sImg.Height
            $srcW = [int]($sImg.Height * $screenAspect)
            $srcX = [int](($sImg.Width - $srcW) / 2)
            $srcY = 0
        } else {
            $srcW = $sImg.Width
            $srcH = [int]($sImg.Width / $screenAspect)
            $srcX = 0
            $srcY = [int](($sImg.Height - $srcH) / 2)
        }

        $srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcW, $srcH)
        $g.DrawImage($sImg, $screenRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $sImg.Dispose()
    } else {
        $fallbackBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(12, 22, 45))
        $g.FillRectangle($fallbackBrush, $screenRect)
        $fallbackBrush.Dispose()
    }

    # Notch
    if ($DeviceType -ne "Laptop") {
        $camW = [int]($frameW * 0.20)
        $camH = 14
        $camX = [int]($frameX + (($frameW - $camW) / 2))
        $camY = $frameY + 4
        $camBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(10, 10, 15))
        $g.FillRectangle($camBrush, $camX, $camY, $camW, $camH)
        $camBrush.Dispose()
    }

    # Cleanup & Save
    $goldBrush.Dispose()
    $whiteBrush.Dispose()
    $tagBgBrush.Dispose()
    $g.Dispose()

    $bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created: $OutFile ($CanvasWidth x $CanvasHeight)"
}

Write-Host "=== Generating Phone Screenshots (1080 x 2400) ==="
foreach ($s in $slides) {
    $outPath = Join-Path $phoneDir ($s.Id + ".png")
    Generate-Device-Slide 1080 2400 $s "Phone" $outPath
}

Write-Host "=== Generating 7-inch Tablet Screenshots (1200 x 1920) ==="
foreach ($s in $slides) {
    $outPath = Join-Path $tab7Dir ($s.Id + ".png")
    Generate-Device-Slide 1200 1920 $s "Tablet7" $outPath
}

Write-Host "=== Generating 10-inch Tablet / iPad Screenshots (1600 x 2560) ==="
foreach ($s in $slides) {
    $outPath = Join-Path $tab10Dir ($s.Id + ".png")
    Generate-Device-Slide 1600 2560 $s "Tablet10" $outPath
}

Write-Host "=== Generating Laptop / Desktop Screenshots (1920 x 1080) ==="
foreach ($s in $slides) {
    $outPath = Join-Path $laptopDir ($s.Id + ".png")
    Generate-Device-Slide 1920 1080 $s "Laptop" $outPath
}

Write-Host "=== SUCCESS: All 28 Device Mockup Screenshots Generated! ==="
