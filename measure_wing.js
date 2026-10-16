const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  for (const filename of ['royal_card_wing_teal_full.png', 'royal_card_wing_purple_full.png']) {
    const b64 = fs.readFileSync('application/assets/images/' + filename).toString('base64');
    await page.setContent(`<img id="img" src="data:image/png;base64,${b64}" /><canvas id="c"></canvas>`);
    const pos = await page.evaluate(() => {
      const img = document.getElementById('img');
      const c = document.getElementById('c');
      c.width = img.naturalWidth;
      c.height = img.naturalHeight;
      const ctx = c.getContext('2d');
      ctx.drawImage(img, 0, 0);
      const id = ctx.getImageData(0, 0, c.width, c.height);
      
      let minX = c.width, maxX = 0, minY = c.height, maxY = 0;
      for (let y = 10; y < 160; y++) {
        for (let x = 20; x < c.width - 5; x++) {
          const idx = (y * c.width + x) * 4;
          const r = id.data[idx], g = id.data[idx+1], b = id.data[idx+2];
          // Face cream color
          if (r > 210 && g > 200 && b > 180) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      return { w: c.width, h: c.height, minX, maxX, minY, maxY, cx: (minX+maxX)/2, cy: (minY+maxY)/2, diaX: maxX - minX, diaY: maxY - minY };
    });
    console.log(filename, pos);
  }
  await browser.close();
  process.exit(0);
})();
