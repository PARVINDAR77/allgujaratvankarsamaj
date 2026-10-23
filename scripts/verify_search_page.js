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

  console.log('Navigating to http://localhost:5055/#/search ...');
  await page.goto('http://localhost:5055/#/search', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 6000));

  await page.screenshot({ path: 'screenshot_search_web_top.png' });
  console.log('Saved screenshot_search_web_top.png');

  // Scroll down a bit to see cards and pagination
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 600 });
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'screenshot_search_web_scrolled.png' });
  console.log('Saved screenshot_search_web_scrolled.png');

  // Also test mobile viewport 390x844
  await page.setViewport({ width: 390, height: 844 });
  await page.goto('http://localhost:5055/#/search', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 5000));
  await page.screenshot({ path: 'screenshot_search_web_mobile.png' });
  console.log('Saved screenshot_search_web_mobile.png');

  await browser.close();
  console.log('Finished capturing search page screenshots!');
})();
