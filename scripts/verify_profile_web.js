const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1080 });

  console.log('Navigating directly to profile-details?id=d651408e-a133-4989-ae72-3a5efdaba695 ...');
  await page.goto('http://localhost:5055/#/profile-details?id=d651408e-a133-4989-ae72-3a5efdaba695', { waitUntil: 'networkidle2', timeout: 35000 });
  await new Promise(r => setTimeout(r, 6000));

  await page.screenshot({ path: 'screenshot_profile_web_top.png' });
  console.log('Saved screenshot_profile_web_top.png');

  // Scroll down to see middle sections
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 700 });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: 'screenshot_profile_web_mid.png' });
  console.log('Saved screenshot_profile_web_mid.png');

  // Scroll down to see bottom and footer
  await page.mouse.wheel({ deltaY: 800 });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: 'screenshot_profile_web_bottom.png' });
  console.log('Saved screenshot_profile_web_bottom.png');

  // Mobile test 390x844
  await page.setViewport({ width: 390, height: 844 });
  await page.goto('http://localhost:5055/#/profile-details?id=d651408e-a133-4989-ae72-3a5efdaba695', { waitUntil: 'networkidle2', timeout: 35000 });
  await new Promise(r => setTimeout(r, 5000));
  await page.screenshot({ path: 'screenshot_profile_mobile.png' });
  console.log('Saved screenshot_profile_mobile.png');

  await browser.close();
  console.log('Finished capturing all profile screenshots!');
})();
