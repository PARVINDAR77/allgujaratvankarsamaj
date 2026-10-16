const puppeteer = require('puppeteer');
const fs = require('fs');

(async() => {
  const browser = await puppeteer.launch({headless:'new'});
  const page = await browser.newPage();
  const b64 = fs.readFileSync('application/assets/images/samaj_super_stars_poster.jpeg').toString('base64');
  await page.setContent('<img id="i" src="data:image/jpeg;base64,' + b64 + '" />');
  const dims = await page.evaluate(() => {
    const i = document.getElementById('i');
    return { w: i.naturalWidth, h: i.naturalHeight, ratio: i.naturalHeight / i.naturalWidth };
  });
  console.log(dims);
  await browser.close();
})();
