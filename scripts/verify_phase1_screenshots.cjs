const puppeteer = require('puppeteer');
const path = require('path');

async function verifyPhase1() {
  console.log('Verifying Phase 1 Screens on Web (Boxes 1, 2, 3)...');
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

  // --- Box 1: Pavan Prernadata ---
  console.log('\n--- Testing Box 1: Pavan Prernadata (/pavan-prernadata) ---');
  await page.goto('http://localhost:5055/#/pavan-prernadata', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot1Top = path.resolve(__dirname, '../screenshot_box1_pavan_prernadata_top.png');
  await page.screenshot({ path: shot1Top });
  console.log(`Saved: ${shot1Top}`);

  await page.mouse.move(720, 500);
  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot1Mid = path.resolve(__dirname, '../screenshot_box1_pavan_prernadata_mid.png');
  await page.screenshot({ path: shot1Mid });
  console.log(`Saved: ${shot1Mid}`);

  // --- Box 2: Samaj Super Stars ---
  console.log('\n--- Testing Box 2: Samaj Super Stars (/samaj-super-stars) ---');
  await page.goto('http://localhost:5055/#/samaj-super-stars', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot2Top = path.resolve(__dirname, '../screenshot_box2_samaj_super_stars_top.png');
  await page.screenshot({ path: shot2Top });
  console.log(`Saved: ${shot2Top}`);

  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot2Mid = path.resolve(__dirname, '../screenshot_box2_samaj_super_stars_mid.png');
  await page.screenshot({ path: shot2Mid });
  console.log(`Saved: ${shot2Mid}`);

  // --- Box 3: Samaj Ratna ---
  console.log('\n--- Testing Box 3: Samaj Ratna (/samaj-ratna) ---');
  await page.goto('http://localhost:5055/#/samaj-ratna', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3500));
  console.log(`Landed on: ${page.url()}`);
  const shot3Top = path.resolve(__dirname, '../screenshot_box3_samaj_ratna_top.png');
  await page.screenshot({ path: shot3Top });
  console.log(`Saved: ${shot3Top}`);

  await page.mouse.wheel({ deltaY: 650 });
  await new Promise(r => setTimeout(r, 1500));
  const shot3Mid = path.resolve(__dirname, '../screenshot_box3_samaj_ratna_mid.png');
  await page.screenshot({ path: shot3Mid });
  console.log(`Saved: ${shot3Mid}`);

  await browser.close();
  console.log('\nAll Phase 1 screenshots captured successfully!');
}

verifyPhase1().catch(err => {
  console.error('Error during verification:', err);
  process.exit(1);
});
