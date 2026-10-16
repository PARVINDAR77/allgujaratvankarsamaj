const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const b64 = fs.readFileSync('application/assets/images/royal_card_wing_teal_full.png').toString('base64');
  await page.setContent('<img id="img" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
  
  const alphaCheck = await page.evaluate(() => {
    const img = document.getElementById('img');
    const c = document.getElementById('c');
    c.width = img.naturalWidth;
    c.height = img.naturalHeight;
    const ctx = c.getContext('2d');
    ctx.drawImage(img, 0, 0);
    const data = ctx.getImageData(0, 0, c.width, c.height).data;
    
    // Check right-top edge (x=180, y=200)
    const idx = (200 * c.width + 180) * 4;
    return {
      w: c.width,
      h: c.height,
      alphaAtRight: data[idx + 3],
      r: data[idx], g: data[idx+1], b: data[idx+2]
    };
  });
  console.log('royal_card_wing_teal_full right edge:', alphaCheck);
  await browser.close();
  process.exit(0);
})();
