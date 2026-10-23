const puppeteer = require('puppeteer');
const path = require('path');

const routes = [
  { name: 'home', path: '/main-poster' },
  { name: 'matrimony', path: '/home' },
  { name: 'box1_pavan_prernadata', path: '/pavan-prernadata' },
  { name: 'box2_samaj_super_stars', path: '/samaj-super-stars' },
  { name: 'box3_samaj_ratna', path: '/samaj-ratna' },
  { name: 'box4_education', path: '/education' },
  { name: 'box5_unity', path: '/advertisement?section=HOME_UNITY' },
  { name: 'box6_statistics', path: '/statistics' },
  { name: 'box7_birthdays', path: '/birthdays' },
  { name: 'box8_strong_roots', path: '/advertisement?section=HOME_STRONG_ROOTS' },
  { name: 'govt_employees', path: '/government-employees' },
  { name: 'private_employees', path: '/private-employees' },
];

const viewports = [
  { label: 'mobile', width: 390, height: 844 },
  { label: 'tablet', width: 820, height: 1180 },
];

async function runAudit() {
  console.log('Starting Responsive Web Audit for Mobile (390px) and Tablet (820px)...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  page.on('console', msg => {
    const text = msg.text();
    if (text.includes('overflowed by') || text.includes('EXCEPTION') || text.includes('RenderFlex')) {
      console.error(`[FLUTTER OVERFLOW/ERROR]: ${text}`);
    }
  });

  // Login session
  await page.setViewport({ width: 1200, height: 800 });
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

  for (const vp of viewports) {
    console.log(`\n=================== AUDITING VIEWPORT: ${vp.label.toUpperCase()} (${vp.width}x${vp.height}) ===================`);
    await page.setViewport({ width: vp.width, height: vp.height });

    for (const r of routes) {
      console.log(`Checking ${r.name} at ${vp.label}...`);
      await page.goto(`http://localhost:5055/#${r.path}`, { waitUntil: 'networkidle0', timeout: 30000 });
      await new Promise(res => setTimeout(res, 2500));

      const screenshotPath = path.resolve(__dirname, `../audit_${vp.label}_${r.name}.png`);
      await page.screenshot({ path: screenshotPath });
      console.log(`Saved screenshot: ${screenshotPath}`);
    }
  }

  await browser.close();
  console.log('\nResponsive audit finished successfully!');
}

runAudit().catch(err => {
  console.error('Audit failed:', err);
  process.exit(1);
});
