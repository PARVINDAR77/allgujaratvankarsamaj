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

  console.log('Navigating to http://localhost:5055/#/match ...');
  await page.goto('http://localhost:5055/#/match', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 7000));

  await page.screenshot({ path: 'screenshot_match_web_top.png' });
  console.log('Saved screenshot_match_web_top.png');

  // Click on the 4th tab: "સ્માર્ટ મેળ (Smart)"
  // Find tabs by evaluating or mouse click.
  // The tab bar is centered around y ~ 350. Let's click the Smart tab.
  // Or click the button "સ્માર્ટ મેળ જુઓ (Smart)" on the info card!
  console.log('Clicking Smart Matches tab at (1185, 380)...');
  await page.mouse.click(1185, 380);
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: 'screenshot_match_web_smart_tab.png' });
  console.log('Saved screenshot_match_web_smart_tab.png');


  // Scroll down a bit
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 600 });
  await new Promise(r => setTimeout(r, 2000));

  await page.screenshot({ path: 'screenshot_match_web_scrolled.png' });
  console.log('Saved screenshot_match_web_scrolled.png');

  // Test mobile viewport 390x844
  await page.setViewport({ width: 390, height: 844 });
  await page.goto('http://localhost:5055/#/match', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 5000));
  await page.screenshot({ path: 'screenshot_match_web_mobile.png' });
  console.log('Saved screenshot_match_web_mobile.png');

  await browser.close();
  console.log('Finished capturing match page screenshots!');
})();
