const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function main() {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  const imgPath = path.resolve('layoutimages/WhatsApp Image 2026-10-21 at 2.30.17 PM.jpeg');
  const base64 = fs.readFileSync(imgPath).toString('base64');

  await page.setContent(`
    <!DOCTYPE html>
    <html>
      <body style="margin:0;">
        <canvas id="c"></canvas>
        <script>
          const img = new Image();
          img.onload = () => {
            const c = document.getElementById('c');
            c.width = img.naturalWidth;
            c.height = img.naturalHeight;
            const ctx = c.getContext('2d');
            ctx.drawImage(img, 0, 0);

            // Let's analyze top/bottom bars or left/right bars
            // Check top row vs bottom row
            window.ready = true;
            window.dims = { w: img.naturalWidth, h: img.naturalHeight };
          };
          img.src = 'data:image/jpeg;base64,${base64}';
        </script>
      </body>
    </html>
  `);

  await page.waitForFunction('window.ready === true');
  const dims = await page.evaluate(() => window.dims);
  console.log('Dims:', dims);

  // Let's sample edges to see if there is any letterboxing/pillarboxing
  const cropInfo = await page.evaluate(() => {
    const c = document.getElementById('c');
    const ctx = c.getContext('2d');
    const w = c.width;
    const h = c.height;

    // Check top edge: find where the blurred bar ends
    // Usually a black/dark line separates the blurred bar
    // Let's inspect along vertical line x = w / 2
    const midX = Math.floor(w / 2);
    const col = ctx.getImageData(midX, 0, 1, h).data;
    
    // Also let's inspect horizontal lines
    let topY = 0;
    let botY = h;

    // In WhatsApp screenshot, top ~50-60px has blurred bar with dark border
    // Let's check diff between y and y+1
    for (let y = 10; y < 150; y++) {
      let diff = 0;
      for (let x = 100; x < w - 100; x += 50) {
        const i1 = (y * w + x) * 4;
        const i2 = ((y + 1) * w + x) * 4;
        diff += Math.abs(col[i1] - col[i2]) + Math.abs(col[i1+1] - col[i2+1]) + Math.abs(col[i1+2] - col[i2+2]);
      }
    }

    return { w, h };
  });

  console.log('Dims:', cropInfo);

  // Let's render cropped image to file
  // Notice in the original image, the painting has top/bottom blur bars:
  // Top bar: y = 0 to 48. Bottom bar: y = 1100 to 1149.
  // Let's inspect rows around 45-55 and 1090-1110
  const barBounds = await page.evaluate(() => {
    const c = document.getElementById('c');
    const ctx = c.getContext('2d');
    const w = c.width;
    const h = c.height;
    
    // Let's find horizontal lines where gradient/blur changes sharply
    const imgData = ctx.getImageData(0, 0, w, h).data;
    
    let bestTop = 0;
    let maxTopScore = 0;
    for (let y = 20; y < 120; y++) {
      let score = 0;
      for (let x = 200; x < w - 200; x += 20) {
        const idx1 = (y * w + x) * 4;
        const idx2 = ((y + 2) * w + x) * 4;
        score += Math.abs(imgData[idx1] - imgData[idx2]) +
                 Math.abs(imgData[idx1+1] - imgData[idx2+1]) +
                 Math.abs(imgData[idx1+2] - imgData[idx2+2]);
      }
      if (score > maxTopScore) {
        maxTopScore = score;
        bestTop = y;
      }
    }

    let bestBot = h;
    let maxBotScore = 0;
    for (let y = h - 120; y < h - 20; y++) {
      let score = 0;
      for (let x = 200; x < w - 200; x += 20) {
        const idx1 = (y * w + x) * 4;
        const idx2 = ((y + 2) * w + x) * 4;
        score += Math.abs(imgData[idx1] - imgData[idx2]) +
                 Math.abs(imgData[idx1+1] - imgData[idx2+1]) +
                 Math.abs(imgData[idx1+2] - imgData[idx2+2]);
      }
      if (score > maxBotScore) {
        maxBotScore = score;
        bestBot = y + 2;
      }
    }

    return { bestTop, bestBot, maxTopScore, maxBotScore };
  });

  console.log('Bar bounds detected:', barBounds);

  // Crop to clean painting and save as application/assets/images/buddha_meditation_sacred.jpg
  const croppedDataUrl = await page.evaluate((top, bot) => {
    const c = document.getElementById('c');
    const w = c.width;
    const h = bot - top;
    const cropCanvas = document.createElement('canvas');
    cropCanvas.width = w;
    cropCanvas.height = h;
    const cropCtx = cropCanvas.getContext('2d');
    cropCtx.drawImage(c, 0, top, w, h, 0, 0, w, h);
    return cropCanvas.toDataURL('image/jpeg', 0.95);
  }, barBounds.bestTop, barBounds.bestBot);

  const base64Data = croppedDataUrl.replace(/^data:image\/jpeg;base64,/, '');
  const outPath1 = path.resolve('application/assets/images/buddha_meditation_sacred.jpg');
  const outPath2 = path.resolve('application/build/web/assets/assets/images/buddha_meditation_sacred.jpg');
  fs.writeFileSync(outPath1, Buffer.from(base64Data, 'base64'));
  if (fs.existsSync(path.dirname(outPath2))) {
    fs.writeFileSync(outPath2, Buffer.from(base64Data, 'base64'));
  }
  console.log('Saved pristine cropped Buddha image to:', outPath1);

  await browser.close();
}

main().catch(console.error);
