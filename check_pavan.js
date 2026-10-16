const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

(async () => {
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 412, height: 915 }); // Mobile viewport

    console.log('Navigating to Pavan Prernadata live page...');
    await page.goto('https://allgujaratvankarsamaj.com/#/pavan-prernadata', {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    console.log('Waiting 6s for Flutter canvas/engine rendering...');
    await new Promise(r => setTimeout(r, 6000));

    const outPath = path.join(__dirname, 'pavan_live_screenshot.png');
    await page.screenshot({ path: outPath });
    console.log('Screenshot saved to:', outPath);

    await browser.close();
  } catch (err) {
    console.error('Error running puppeteer check:', err);
  }
})();
