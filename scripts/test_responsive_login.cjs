const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const VIEWPORTS = [
  { name: 'mobile_390x844', width: 390, height: 844 },
  { name: 'tablet_768x1024', width: 768, height: 1024 },
  { name: 'laptop_800x600', width: 800, height: 600 },
  { name: 'laptop_1024x768', width: 1024, height: 768 },
  { name: 'desktop_1366x768', width: 1366, height: 768 },
];

async function run() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  for (const vp of VIEWPORTS) {
    console.log(`Testing viewport ${vp.name} (${vp.width}x${vp.height})...`);
    const page = await browser.newPage();
    await page.setViewport({ width: vp.width, height: vp.height });

    // Initial load
    await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle2', timeout: 30000 });
    await new Promise(r => setTimeout(r, 3000));

    const shot1 = path.join(__dirname, `../verified_login_${vp.name}_initial.png`);
    await page.screenshot({ path: shot1, fullPage: false });
    console.log(`  Saved initial screenshot: ${shot1}`);

    // Refresh test
    await page.reload({ waitUntil: 'networkidle2', timeout: 30000 });
    await new Promise(r => setTimeout(r, 3000));

    const shot2 = path.join(__dirname, `../verified_login_${vp.name}_refresh.png`);
    await page.screenshot({ path: shot2, fullPage: false });
    console.log(`  Saved refresh screenshot: ${shot2}`);

    await page.close();
  }

  await browser.close();
  console.log('All login viewport tests completed successfully!');
}

run().catch(console.error);
