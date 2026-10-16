const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const b64 = fs.readFileSync('C:/Users/SEO STZK/.gemini/antigravity-ide/brain/2b2ec6ac-ebc1-4604-94fb-05869bc34915/.user_uploaded/media_1791863605198.png').toString('base64');
  await page.setContent('<img id="target" src="data:image/png;base64,' + b64 + '" /><canvas id="c"></canvas>');
  
  await page.evaluate(() => {
    const img = document.getElementById('target');

    // 1. Bottom Lotus Trim (strictly below Card 4)
    // Card 4 ends at Y=904. Lotus trim is between Y=905 and Y=965.
    const lotusC = document.createElement('canvas');
    lotusC.width = 460;
    lotusC.height = 62;
    const lotusCtx = lotusC.getContext('2d');
    lotusCtx.drawImage(img, 0, 905, 460, 62, 0, 0, 460, 62);
    window.cleanLotus = lotusC.toDataURL('image/png');

    // 2. Card 3 Wing (Teal wing with house icon)
    // Card 3 starts at Y=616, height=138
    const c3 = document.createElement('canvas');
    c3.width = 126;
    c3.height = 138;
    const ctx3 = c3.getContext('2d');
    ctx3.drawImage(img, 8, 616, 126, 138, 0, 0, 126, 138);
    window.c3Data = c3.toDataURL('image/png');

    // 3. Card 4 Wing (Purple wing with house icon)
    // Card 4 starts at Y=762, height=138
    const c4 = document.createElement('canvas');
    c4.width = 126;
    c4.height = 138;
    const ctx4 = c4.getContext('2d');
    ctx4.drawImage(img, 8, 762, 126, 138, 0, 0, 126, 138);
    window.c4Data = c4.toDataURL('image/png');

    // 4. Extract Banner Right Feather Motif
    // In banner (Y=108 to 198), the feather is at the right edge between X=370 and X=455
    const bFeather = document.createElement('canvas');
    bFeather.width = 90;
    bFeather.height = 92;
    const bfCtx = bFeather.getContext('2d');
    bfCtx.drawImage(img, 368, 108, 90, 92, 0, 0, 90, 92);
    window.bannerFeatherData = bFeather.toDataURL('image/png');

    // 5. Clean Card Wing base without icon (just the circular golden ring with cream interior)
    // We can clear the inside of the circle (radius 27) with #FFFDF8
    const baseTeal = document.createElement('canvas');
    baseTeal.width = 126;
    baseTeal.height = 138;
    const btCtx = baseTeal.getContext('2d');
    btCtx.drawImage(img, 8, 328, 126, 138, 0, 0, 126, 138);
    // Find circle center: in 126x138, center is at cx=70, cy=68, radius=27
    btCtx.save();
    btCtx.beginPath();
    btCtx.arc(69, 68, 25.5, 0, Math.PI * 2);
    btCtx.fillStyle = '#FFFDF8';
    btCtx.fill();
    btCtx.restore();
    window.tealWingAperture = baseTeal.toDataURL('image/png');

    // Base Purple
    const basePurple = document.createElement('canvas');
    basePurple.width = 126;
    basePurple.height = 138;
    const bpCtx = basePurple.getContext('2d');
    bpCtx.drawImage(img, 8, 472, 126, 138, 0, 0, 126, 138);
    bpCtx.save();
    bpCtx.beginPath();
    bpCtx.arc(69, 68, 25.5, 0, Math.PI * 2);
    bpCtx.fillStyle = '#FFFDF8';
    bpCtx.fill();
    bpCtx.restore();
    window.purpleWingAperture = basePurple.toDataURL('image/png');
  });

  const cleanLotus = await page.evaluate(() => window.cleanLotus);
  fs.writeFileSync('application/assets/images/royal_bottom_lotus_perfect.png', Buffer.from(cleanLotus.split(',')[1], 'base64'));

  const c3Data = await page.evaluate(() => window.c3Data);
  fs.writeFileSync('application/assets/images/wing_card_teal_house.png', Buffer.from(c3Data.split(',')[1], 'base64'));

  const c4Data = await page.evaluate(() => window.c4Data);
  fs.writeFileSync('application/assets/images/wing_card_purple_house.png', Buffer.from(c4Data.split(',')[1], 'base64'));

  const bannerFeatherData = await page.evaluate(() => window.bannerFeatherData);
  fs.writeFileSync('application/assets/images/banner_feather_perfect.png', Buffer.from(bannerFeatherData.split(',')[1], 'base64'));

  const tealWingAperture = await page.evaluate(() => window.tealWingAperture);
  fs.writeFileSync('application/assets/images/wing_teal_aperture.png', Buffer.from(tealWingAperture.split(',')[1], 'base64'));

  const purpleWingAperture = await page.evaluate(() => window.purpleWingAperture);
  fs.writeFileSync('application/assets/images/wing_purple_aperture.png', Buffer.from(purpleWingAperture.split(',')[1], 'base64'));

  console.log('All refined assets created successfully!');
  await browser.close();
  process.exit(0);
})();
