const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function verifyBuddhaLogin() {
  console.log('Launching browser to verify Buddha login page...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const artifactDir = 'C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b';

  const viewports = [
    { name: 'desktop_1920x1080', width: 1920, height: 1080 },
    { name: 'laptop_1440x900', width: 1440, height: 900 },
    { name: 'compact_1280x768', width: 1280, height: 768 }
  ];

  for (const vp of viewports) {
    const page = await browser.newPage();
    await page.setViewport({ width: vp.width, height: vp.height, deviceScaleFactor: 1 });

    console.log(`Navigating to http://localhost:5055/#/login at ${vp.width}x${vp.height}...`);
    try {
      await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle2', timeout: 30000 });
      // Wait extra 3 seconds for Flutter canvas and web fonts to fully render
      await new Promise(r => setTimeout(r, 4000));

      const screenshotPath = path.join(artifactDir, `verify_login_${vp.name}.png`);
      await page.screenshot({ path: screenshotPath, fullPage: false });
      console.log(`Screenshot saved for ${vp.name} to: ${screenshotPath}`);
    } catch (e) {
      console.error(`Error verifying ${vp.name}:`, e.message);
    } finally {
      await page.close();
    }
  }

  await browser.close();
  console.log('Verification completed.');
}

verifyBuddhaLogin().catch(err => {
  console.error('Verification failed:', err);
  process.exit(1);
});
