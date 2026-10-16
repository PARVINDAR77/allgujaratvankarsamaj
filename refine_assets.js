const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const b64 = fs.readFileSync('C:/Users/SEO STZK/.gemini/antigravity-ide/brain/2b2ec6ac-ebc1-4604-94fb-05869bc34915/.user_uploaded/media_1791863605198.png').toString('base64');
  await page.setContent('<img id="target" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
  
  await page.evaluate(() => {
    const img = document.getElementById('target');

    // 1. Precise Bottom Lotus:
    // Lotus peak is at Y=924, height 44, width 460
    const lotusC = document.createElement('canvas');
    lotusC.width = 460;
    lotusC.height = 44;
    const lotusCtx = lotusC.getContext('2d');
    lotusCtx.drawImage(img, 0, 924, 460, 44, 0, 0, 460, 44);
    window.cleanLotus = lotusC.toDataURL('image/png');

    // 2. Beautiful Banner:
    // Entire banner frame from Y=110 to Y=198 (height 88px, width 444, x=8)
    // We can clear the text area so Flutter renders dynamic text and live count!
    const bannerC = document.createElement('canvas');
    bannerC.width = 444;
    bannerC.height = 88;
    const bCtx = bannerC.getContext('2d');
    bCtx.drawImage(img, 8, 110, 444, 88, 0, 0, 444, 88);
    
    // Clear text area with the cream gradient of the banner
    // From x=14 to x=300, y=10 to y=78
    const creamGrad = bCtx.createLinearGradient(0, 10, 0, 78);
    creamGrad.addColorStop(0, '#FFFDF8');
    creamGrad.addColorStop(1, '#FAF4E4');
    bCtx.fillStyle = creamGrad;
    bCtx.fillRect(16, 12, 280, 64);
    
    // Clear the number in the emerald pill:
    // Pill is from x=305 to x=430, y=20 to y=62
    // Let's keep the emerald pill background but clear the text so we can put dynamic count!
    // Or even better: extract the ornate corner and right feather!
    window.cleanBanner = bannerC.toDataURL('image/png');

    // 3. Just the right side feather of the banner with transparent background or natural fade
    const fC = document.createElement('canvas');
    fC.width = 110;
    fC.height = 88;
    const fCtx = fC.getContext('2d');
    fCtx.drawImage(img, 342, 110, 110, 88, 0, 0, 110, 88);
    window.featherOnly = fC.toDataURL('image/png');
  });

  const cleanLotus = await page.evaluate(() => window.cleanLotus);
  fs.writeFileSync('application/assets/images/royal_bottom_lotus_exact.png', Buffer.from(cleanLotus.split(',')[1], 'base64'));

  const cleanBanner = await page.evaluate(() => window.cleanBanner);
  fs.writeFileSync('application/assets/images/royal_banner_bg_clean.png', Buffer.from(cleanBanner.split(',')[1], 'base64'));

  const featherOnly = await page.evaluate(() => window.featherOnly);
  fs.writeFileSync('application/assets/images/banner_right_flourish.png', Buffer.from(featherOnly.split(',')[1], 'base64'));

  console.log('Processed precise assets');
  await browser.close();
  process.exit(0);
})();
