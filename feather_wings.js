const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const files = [
    'wing_card_teal_perfect.png',
    'wing_card_purple_perfect.png',
    'wing_card_teal_house.png',
    'wing_card_purple_house.png',
    'wing_teal_aperture.png',
    'wing_purple_aperture.png',
    'wing_card_purple_building.png'
  ];

  for (const f of files) {
    const b64 = fs.readFileSync('application/assets/images/' + f).toString('base64');
    await page.setContent('<img id="img" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
    
    const featheredB64 = await page.evaluate(() => {
      const img = document.getElementById('img');
      const c = document.getElementById('c');
      c.width = img.naturalWidth;
      c.height = img.naturalHeight;
      const ctx = c.getContext('2d');
      ctx.drawImage(img, 0, 0);

      // We fade the right 24 pixels (from x = c.width - 24 to c.width)
      const fadeStart = c.width - 24;
      const id = ctx.getImageData(0, 0, c.width, c.height);
      for (let y = 0; y < c.height; y++) {
        for (let x = fadeStart; x < c.width; x++) {
          const idx = (y * c.width + x) * 4;
          const factor = (c.width - 1 - x) / 23.0; // 1 at fadeStart, 0 at c.width - 1
          id.data[idx + 3] = Math.round(id.data[idx + 3] * Math.max(0, factor));
        }
      }
      ctx.putImageData(id, 0, 0);
      return c.toDataURL('image/png');
    });

    fs.writeFileSync('application/assets/images/' + f, Buffer.from(featheredB64.split(',')[1], 'base64'));
    console.log('Feathered right edge of', f);
  }

  await browser.close();
  process.exit(0);
})();
