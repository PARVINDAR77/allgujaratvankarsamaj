const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  // Test wing_card_teal_perfect.png
  const b64 = fs.readFileSync('application/assets/images/wing_card_teal_perfect.png').toString('base64');
  await page.setContent('<img id="img" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
  
  const metrics = await page.evaluate(() => {
    const img = document.getElementById('img');
    const c = document.getElementById('c');
    c.width = img.naturalWidth;
    c.height = img.naturalHeight;
    const ctx = c.getContext('2d');
    ctx.drawImage(img, 0, 0);
    const data = ctx.getImageData(0, 0, c.width, c.height).data;

    // Find the outer gold ring of the medallion
    // In wing_card_teal_perfect (w=126, h=138)
    // Find pixels of the white circle inside the gold ring
    let minX = c.width, maxX = 0, minY = c.height, maxY = 0;
    for (let y = 15; y < 115; y++) {
      for (let x = 20; x < 115; x++) {
        const idx = (y * c.width + x) * 4;
        const r = data[idx], g = data[idx+1], b = data[idx+2];
        // The inner circle is ivory white: r > 240, g > 235, b > 225
        if (r > 240 && g > 235 && b > 220) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    return {
      w: c.width,
      h: c.height,
      minX, maxX, minY, maxY,
      cx: (minX + maxX) / 2,
      cy: (minY + maxY) / 2,
      diaX: maxX - minX,
      diaY: maxY - minY
    };
  });
  
  console.log('wing_card_teal_perfect metrics:', metrics);
  await browser.close();
  process.exit(0);
})();
