const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  console.log('Navigating to http://localhost:5055/#/home ...');
  await page.goto('http://localhost:5055/#/home', { waitUntil: 'networkidle2', timeout: 35000 });
  await new Promise(r => setTimeout(r, 6000));

  // Screenshot header section
  await page.screenshot({ path: 'screenshot_new_header_logo.png' });
  console.log('Saved screenshot_new_header_logo.png');

  // Scroll to footer
  console.log('Scrolling to footer...');
  await page.evaluate(() => {
    window.scrollTo(0, document.body.scrollHeight);
  });
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 4000 });
  await new Promise(r => setTimeout(r, 3000));

  await page.screenshot({ path: 'screenshot_new_footer_logo.png' });
  console.log('Saved screenshot_new_footer_logo.png');

  // Also check candidate profile page
  await page.goto('http://localhost:5055/#/profile-details?id=d651408e-a133-4989-ae72-3a5efdaba695', { waitUntil: 'networkidle2', timeout: 35000 });
  await new Promise(r => setTimeout(r, 4000));
  await page.screenshot({ path: 'screenshot_profile_with_new_header.png' });
  console.log('Saved screenshot_profile_with_new_header.png');

  await browser.close();
  console.log('Done verifying new logo in header & footer!');
})();
