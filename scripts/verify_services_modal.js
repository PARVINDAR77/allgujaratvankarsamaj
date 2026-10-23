const puppeteer = require('puppeteer');

(async () => {
  console.log('Launching browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1080 });

  console.log('Navigating to http://localhost:5055/#/samaj-services ...');
  await page.goto('http://localhost:5055/#/samaj-services', { waitUntil: 'networkidle2', timeout: 30000 });

  console.log('Waiting for Flutter app to render...');
  await new Promise(r => setTimeout(r, 6000));

  // In the initial view (scroll = 0):
  // The tab bar is at y = 889.
  // Left tab: x = 282, y = 889 (Professionals)
  // Right tab: x = 718, y = 889 (Categories)
  console.log('Clicking "સેવા કેટેગરી (Categories)" tab at (718, 889)...');
  await page.mouse.click(718, 889);
  await new Promise(r => setTimeout(r, 2500));

  await page.screenshot({ path: 'screenshot_categories_tab_v20.png' });
  console.log('Saved screenshot_categories_tab_v20.png');

  // Let's also test clicking at (650, 889) in case 718 was near an edge
  console.log('Trying click at (650, 889)...');
  await page.mouse.click(650, 889);
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'screenshot_categories_tab_v20_after_650.png' });
  console.log('Saved screenshot_categories_tab_v20_after_650.png');

  await browser.close();
  console.log('Done!');
})();
