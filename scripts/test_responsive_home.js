const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const VIEWPORTS = [
  { name: '1920_desktop', width: 1920, height: 1080 },
  { name: '1440_laptop', width: 1440, height: 900 },
  { name: '1024_tablet_landscape', width: 1024, height: 768 },
  { name: '768_tablet_portrait', width: 768, height: 1024 },
  { name: '390_mobile', width: 390, height: 844 },
];

async function run() {
  console.log('Launching browser for responsive verification...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  // Handle dialogs automatically
  page.on('dialog', async dialog => {
    console.log('Dialog popped up:', dialog.message());
    await dialog.dismiss();
  });

  for (const vp of VIEWPORTS) {
    console.log(`\n=== Testing Viewport: ${vp.name} (${vp.width}x${vp.height}) ===`);
    await page.setViewport({ width: vp.width, height: vp.height });
    
    // Clear storage cache key to ensure fresh reload
    await page.goto('http://localhost:5055/#/main-poster', { waitUntil: 'networkidle0', timeout: 30000 });
    
    // Wait for Flutter app initialization
    await new Promise(r => setTimeout(r, 4000));

    // Capture top view
    const topScreenshot = path.resolve(__dirname, `../screenshot_web_${vp.name}_top.png`);
    await page.screenshot({ path: topScreenshot, fullPage: false });
    console.log(`Saved: ${topScreenshot}`);

    // Scroll down to Matrimony Actions & Service Cards
    await page.evaluate(() => window.scrollBy(0, 750));
    await new Promise(r => setTimeout(r, 1000));
    const mid1Screenshot = path.resolve(__dirname, `../screenshot_web_${vp.name}_actions.png`);
    await page.screenshot({ path: mid1Screenshot, fullPage: false });
    console.log(`Saved: ${mid1Screenshot}`);

    // Scroll down to Development Section & Featured Portals
    await page.evaluate(() => window.scrollBy(0, 1000));
    await new Promise(r => setTimeout(r, 1000));
    const mid2Screenshot = path.resolve(__dirname, `../screenshot_web_${vp.name}_portals.png`);
    await page.screenshot({ path: mid2Screenshot, fullPage: false });
    console.log(`Saved: ${mid2Screenshot}`);

    // Scroll down to Community Values & Footer
    await page.evaluate(() => window.scrollBy(0, 1200));
    await new Promise(r => setTimeout(r, 1000));
    const bottomScreenshot = path.resolve(__dirname, `../screenshot_web_${vp.name}_footer.png`);
    await page.screenshot({ path: bottomScreenshot, fullPage: false });
    console.log(`Saved: ${bottomScreenshot}`);
  }

  // Also test /home route
  console.log('\n=== Testing /home Route at 1440x900 ===');
  await page.setViewport({ width: 1440, height: 900 });
  await page.goto('http://localhost:5055/#/home', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  const homeScreenshot = path.resolve(__dirname, '../screenshot_web_home_route_1440.png');
  await page.screenshot({ path: homeScreenshot, fullPage: false });
  console.log(`Saved: ${homeScreenshot}`);

  await browser.close();
  console.log('\nAll responsive tests completed successfully!');
}

run().catch(err => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
