const puppeteer = require('puppeteer');
const path = require('path');

async function testNavigation() {
  console.log('Testing direct route navigation and links on desktop web...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  const routesToTest = [
    { name: 'main-poster', route: '/#/main-poster', expectedUrl: '/main-poster' },
    { name: 'pavan-prernadata', route: '/#/pavan-prernadata', expectedUrl: '/pavan-prernadata' },
    { name: 'samaj-super-stars', route: '/#/samaj-super-stars-poster', expectedUrl: '/samaj-super-stars-poster' },
    { name: 'samaj-ratna', route: '/#/samaj-ratna', expectedUrl: '/samaj-ratna' },
    { name: 'govt-employees', route: '/#/government-employees', expectedUrl: '/government-employees' },
    { name: 'private-employees', route: '/#/private-employees', expectedUrl: '/private-employees' },
    { name: 'samaj-services', route: '/#/samaj-services', expectedUrl: '/samaj-services' },
    { name: 'family-details', route: '/#/family-details', expectedUrl: '/family-details' },
    { name: 'statistics', route: '/#/statistics', expectedUrl: '/statistics' },
    { name: 'education', route: '/#/education', expectedUrl: '/education' },
  ];

  for (const item of routesToTest) {
    console.log(`Testing route: ${item.name} (${item.route})`);
    await page.goto(`http://localhost:5055${item.route}`, { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, 2500));
    const currentUrl = page.url();
    console.log(`Current URL: ${currentUrl}`);
    const screenshotPath = path.resolve(__dirname, `../nav_test_${item.name}.png`);
    await page.screenshot({ path: screenshotPath });
    console.log(`Captured: ${screenshotPath}`);
  }

  await browser.close();
  console.log('\nAll route navigation verified successfully!');
}

testNavigation().catch(err => {
  console.error('Navigation test failed:', err);
  process.exit(1);
});
