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

  await page.goto('http://localhost:5055/#/samaj-services', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 6000));

  // 1. Click Categories tab
  console.log('Clicking Categories tab...');
  await page.mouse.click(1050, 975);
  await new Promise(r => setTimeout(r, 2000));

  // 2. Scroll Flutter view down
  console.log('Scrolling down...');
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 350 });
  await new Promise(r => setTimeout(r, 2000));

  // 3. Click the first service card (Agricultural Services)
  console.log('Clicking Agricultural Services...');
  await page.mouse.click(250, 780);
  
  // Wait 5 seconds for dialog and data resolution
  await new Promise(r => setTimeout(r, 5000));

  await page.screenshot({ path: 'screenshot_service_dialog_v22.png' });
  console.log('Saved screenshot_service_dialog_v22.png');

  await browser.close();
  console.log('Finished!');
})();
