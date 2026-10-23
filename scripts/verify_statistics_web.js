const puppeteer = require('puppeteer');
const path = require('path');

async function verifyStatisticsWeb() {
  console.log('Verifying redesigned LiveStatisticsScreen on web...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  // First visit /login to establish localStorage context
  await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle0', timeout: 30000 });

  // Inject a valid mock JWT token with active profile & verified status so router allows /statistics
  await page.evaluate(() => {
    // Generate valid base64url encoded JWT payload
    const header = btoa(JSON.stringify({ alg: "HS256", typ: "JWT" }));
    const payload = btoa(JSON.stringify({
      sub: "1",
      email: "panjabiparvindar77@gmail.com",
      role: "ADMIN",
      status: "ACTIVE",
      isVerified: true,
      hasProfile: true,
      exp: Math.floor(Date.now() / 1000) + 86400 * 30
    }));
    const fakeToken = `${header}.${payload}.signature`;
    localStorage.setItem('jwt_token', fakeToken);
  });

  console.log('Navigating to http://localhost:5055/#/statistics...');
  await page.goto('http://localhost:5055/#/statistics', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));

  const currentUrl = page.url();
  console.log(`Landed on: ${currentUrl}`);

  // Take top screenshot
  const topShot = path.resolve(__dirname, '../screenshot_statistics_web_top.png');
  await page.screenshot({ path: topShot });
  console.log(`Saved top screenshot: ${topShot}`);

  // Scroll down to capture the 2-column department breakdown and quick links
  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 700 });
  await new Promise(r => setTimeout(r, 2000));
  const midShot = path.resolve(__dirname, '../screenshot_statistics_web_mid.png');
  await page.screenshot({ path: midShot });
  console.log(`Saved mid screenshot: ${midShot}`);

  // Scroll further down to capture footer and shortcuts
  await page.mouse.wheel({ deltaY: 900 });
  await new Promise(r => setTimeout(r, 2000));
  const bottomShot = path.resolve(__dirname, '../screenshot_statistics_web_bottom.png');
  await page.screenshot({ path: bottomShot });
  console.log(`Saved bottom screenshot: ${bottomShot}`);

  // Capture mobile viewport (390x844) to ensure responsive adaptation
  await page.setViewport({ width: 390, height: 844 });
  await page.goto('http://localhost:5055/#/statistics', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 2000));
  const mobileShot = path.resolve(__dirname, '../screenshot_statistics_web_mobile.png');
  await page.screenshot({ path: mobileShot });
  console.log(`Saved mobile screenshot: ${mobileShot}`);

  await browser.close();
  console.log('LiveStatisticsScreen web verification complete!');
}

verifyStatisticsWeb().catch(err => {
  console.error('Verification error:', err);
  process.exit(1);
});
