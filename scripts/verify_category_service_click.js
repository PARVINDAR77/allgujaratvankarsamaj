const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1080 });

  await page.goto('http://localhost:5055/#/samaj-services', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 6000));

  // 1. Click "સેવા કેટેગરી (Categories)" tab at (1050, 975)
  console.log('Clicking Categories tab at (1050, 975)...');
  await page.mouse.click(1050, 975);
  await new Promise(r => setTimeout(r, 2000));

  // 2. Scroll Flutter view down to reveal service grid cards
  console.log('Scrolling down to reveal service cards...');
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 350 });
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'screenshot_agriculture_category_expanded.png' });
  console.log('Saved screenshot_agriculture_category_expanded.png');

  // 3. In the scrolled view, click on the first service card in Agriculture & Farming (e.g. at x = 250, y = 780 or similar)
  console.log('Clicking the first service card in Agriculture & Farming...');
  await page.mouse.click(250, 780);
  await new Promise(r => setTimeout(r, 3500));

  await page.screenshot({ path: 'screenshot_service_providers_dialog_success.png' });
  console.log('Saved screenshot_service_providers_dialog_success.png');

  await browser.close();
  console.log('Finished successfully!');
})();
