const puppeteer = require('puppeteer');
const path = require('path');

async function verifyPhase2() {
  console.log('Verifying Phase 2 Screens on Web (Boxes 4, 5, 7, 8)...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  // 1. Establish context
  await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle0', timeout: 30000 });
  await page.evaluate(() => {
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

  // --- Box 4: Education (/education) ---
  console.log('\n--- Testing Box 4: Education (/education) ---');
  await page.goto('http://localhost:5055/#/education', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot4Top = path.resolve(__dirname, '../screenshot_box4_education_top.png');
  await page.screenshot({ path: shot4Top });
  console.log(`Saved: ${shot4Top}`);

  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot4Mid = path.resolve(__dirname, '../screenshot_box4_education_mid.png');
  await page.screenshot({ path: shot4Mid });
  console.log(`Saved: ${shot4Mid}`);

  // --- Box 5: Unity (/advertisement?section=HOME_UNITY) ---
  console.log('\n--- Testing Box 5: Unity (/advertisement?section=HOME_UNITY) ---');
  await page.goto('http://localhost:5055/#/advertisement?section=HOME_UNITY', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot5Top = path.resolve(__dirname, '../screenshot_box5_unity_top.png');
  await page.screenshot({ path: shot5Top });
  console.log(`Saved: ${shot5Top}`);

  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot5Mid = path.resolve(__dirname, '../screenshot_box5_unity_mid.png');
  await page.screenshot({ path: shot5Mid });
  console.log(`Saved: ${shot5Mid}`);

  // --- Box 7: Service / Felicitations (/birthdays) ---
  console.log('\n--- Testing Box 7: Service / Birthdays (/birthdays) ---');
  await page.goto('http://localhost:5055/#/birthdays', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot7Top = path.resolve(__dirname, '../screenshot_box7_birthdays_top.png');
  await page.screenshot({ path: shot7Top });
  console.log(`Saved: ${shot7Top}`);

  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot7Mid = path.resolve(__dirname, '../screenshot_box7_birthdays_mid.png');
  await page.screenshot({ path: shot7Mid });
  console.log(`Saved: ${shot7Mid}`);

  // --- Box 8: Strong Roots (/advertisement?section=HOME_STRONG_ROOTS) ---
  console.log('\n--- Testing Box 8: Strong Roots (/advertisement?section=HOME_STRONG_ROOTS) ---');
  await page.goto('http://localhost:5055/#/advertisement?section=HOME_STRONG_ROOTS', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot8Top = path.resolve(__dirname, '../screenshot_box8_strong_roots_top.png');
  await page.screenshot({ path: shot8Top });
  console.log(`Saved: ${shot8Top}`);

  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot8Mid = path.resolve(__dirname, '../screenshot_box8_strong_roots_mid.png');
  await page.screenshot({ path: shot8Mid });
  console.log(`Saved: ${shot8Mid}`);

  await browser.close();
  console.log('\nAll Phase 2 screenshots captured successfully!');
}

verifyPhase2().catch(err => {
  console.error('Error during verification:', err);
  process.exit(1);
});
