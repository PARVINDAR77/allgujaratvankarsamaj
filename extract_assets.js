const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const b64 = fs.readFileSync('C:/Users/SEO STZK/.gemini/antigravity-ide/brain/2b2ec6ac-ebc1-4604-94fb-05869bc34915/.user_uploaded/media_1791863605198.png').toString('base64');
  await page.setContent('<img id="target" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
  
  await page.evaluate(() => {
    const img = document.getElementById('target');
    
    // 1. Clean Bottom Lotus Trim (between Y=901 and Y=960, width 460)
    const lotusC = document.createElement('canvas');
    lotusC.width = 460;
    lotusC.height = 58;
    const lotusCtx = lotusC.getContext('2d');
    lotusCtx.drawImage(img, 0, 903, 460, 58, 0, 0, 460, 58);
    window.cleanLotusData = lotusC.toDataURL('image/png');

    // 2. Card 1 Wing (Teal wing with peacock eye, width 126, height 140)
    // Card 1 starts at x=8, y=328, width=444, height=138
    const c1 = document.createElement('canvas');
    c1.width = 126;
    c1.height = 138;
    const ctx1 = c1.getContext('2d');
    ctx1.drawImage(img, 8, 328, 126, 138, 0, 0, 126, 138);
    window.c1Data = c1.toDataURL('image/png');

    // 3. Card 2 Wing (Purple wing with peacock eye, width 126, height 138)
    // Card 2 starts at x=8, y=472, width=444, height=138
    const c2 = document.createElement('canvas');
    c2.width = 126;
    c2.height = 138;
    const ctx2 = c2.getContext('2d');
    ctx2.drawImage(img, 8, 472, 126, 138, 0, 0, 126, 138);
    window.c2Data = c2.toDataURL('image/png');

    // 4. Pure transparent or clean Banner background
    // Banner starts at x=8, y=110, width=444, height=88
    const bC = document.createElement('canvas');
    bC.width = 444;
    bC.height = 88;
    const bCtx = bC.getContext('2d');
    bCtx.drawImage(img, 8, 110, 444, 88, 0, 0, 444, 88);
    window.bannerFullData = bC.toDataURL('image/png');
  });

  const cleanLotusData = await page.evaluate(() => window.cleanLotusData);
  fs.writeFileSync('application/assets/images/royal_bottom_lotus_clean.png', Buffer.from(cleanLotusData.split(',')[1], 'base64'));

  const c1Data = await page.evaluate(() => window.c1Data);
  fs.writeFileSync('application/assets/images/wing_card_teal_perfect.png', Buffer.from(c1Data.split(',')[1], 'base64'));

  const c2Data = await page.evaluate(() => window.c2Data);
  fs.writeFileSync('application/assets/images/wing_card_purple_perfect.png', Buffer.from(c2Data.split(',')[1], 'base64'));

  const bannerFullData = await page.evaluate(() => window.bannerFullData);
  fs.writeFileSync('application/assets/images/royal_banner_frame_perfect.png', Buffer.from(bannerFullData.split(',')[1], 'base64'));

  console.log('All perfect assets extracted!');
  await browser.close();
  process.exit(0);
})();
