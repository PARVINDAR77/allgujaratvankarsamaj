const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1080 });

  page.on('console', msg => console.log('BROWSER_LOG:', msg.type(), msg.text()));
  page.on('pageerror', err => console.log('BROWSER_ERR:', err.message));

  console.log('Navigating to http://localhost:5055/#/family-details ...');
  await page.goto('http://localhost:5055/#/family-details', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 7000));

  await page.screenshot({ path: 'screenshot_family_web_top.png' });
  console.log('Saved screenshot_family_web_top.png');

  // Click on the first card's "સંપૂર્ણ પરિવાર વિગત જુઓ" button
  console.log('Clicking on family card details button...');
  // The first button is at x ~ 290, y ~ 710 in desktop view
  await page.mouse.click(290, 710);
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: 'screenshot_family_web_dialog.png' });
  console.log('Saved screenshot_family_web_dialog.png');

  // Close dialog by clicking outside or pressing Escape
  await page.keyboard.press('Escape');
  await new Promise(r => setTimeout(r, 1000));

  // Scroll down a bit to see cards
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 500 });
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'screenshot_family_web_cards.png' });
  console.log('Saved screenshot_family_web_cards.png');

  // Scroll to bottom to verify footer
  await page.mouse.wheel({ deltaY: 800 });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: 'screenshot_family_web_footer.png' });
  console.log('Saved screenshot_family_web_footer.png');

  // Test mobile viewport 390x844
  await page.setViewport({ width: 390, height: 844 });
  await page.goto('http://localhost:5055/#/family-details', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 5000));
  await page.screenshot({ path: 'screenshot_family_web_mobile.png' });
  console.log('Saved screenshot_family_web_mobile.png');

  await browser.close();
  console.log('Finished capturing family details page screenshots!');
})();
