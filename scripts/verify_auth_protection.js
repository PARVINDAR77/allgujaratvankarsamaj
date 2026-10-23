const puppeteer = require('puppeteer');
const path = require('path');

async function testAuthProtection() {
  console.log('Testing authentication protection and redirect to login after refresh/direct navigation...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  // Clear all localStorage and sessionStorage first to simulate completely unauthenticated visitor
  await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle0', timeout: 30000 });
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });

  const protectedRoutes = [
    { name: 'government-employees', url: 'http://localhost:5055/#/government-employees' },
    { name: 'private-employees', url: 'http://localhost:5055/#/private-employees' },
    { name: 'matrimony-home', url: 'http://localhost:5055/#/home' },
    { name: 'community-main-poster', url: 'http://localhost:5055/#/main-poster' },
    { name: 'candidate-profile-details', url: 'http://localhost:5055/#/candidate-profile-details' },
    { name: 'family-details', url: 'http://localhost:5055/#/family-details' },
    { name: 'root-url', url: 'http://localhost:5055/' },
  ];

  let allPassed = true;

  for (const item of protectedRoutes) {
    console.log(`\nTesting unauthenticated access to: ${item.url}`);
    await page.goto(item.url, { waitUntil: 'networkidle0', timeout: 30000 });
    // Allow Flutter GoRouter to settle its redirect logic
    await new Promise(r => setTimeout(r, 3000));

    const finalUrl = page.url();
    console.log(`Final URL reached: ${finalUrl}`);

    const isLogin = finalUrl.includes('/#/login') || finalUrl.endsWith('/login');
    if (isLogin) {
      console.log(` [PASS] Successfully redirected to /login for ${item.name}`);
    } else {
      console.error(` [FAIL] Expected redirect to /login but landed on ${finalUrl} for ${item.name}`);
      allPassed = false;
    }
  }

  // Now test browser refresh (F5) on protected route
  console.log('\nTesting Browser Refresh (F5 simulation) on http://localhost:5055/#/government-employees...');
  await page.goto('http://localhost:5055/#/government-employees', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 2000));
  console.log('Triggering page reload (F5)...');
  await page.reload({ waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 3000));

  const refreshedUrl = page.url();
  console.log(`URL after refresh: ${refreshedUrl}`);
  if (refreshedUrl.includes('/#/login') || refreshedUrl.endsWith('/login')) {
    console.log(' [PASS] After browser refresh, unauthenticated visitor was strictly redirected to /login!');
  } else {
    console.error(` [FAIL] After refresh, expected /login but landed on: ${refreshedUrl}`);
    allPassed = false;
  }

  // Capture proof screenshot
  const screenshotPath = path.resolve(__dirname, '../screenshot_unauth_redirect_login_verified.png');
  await page.screenshot({ path: screenshotPath });
  console.log(`Captured verification screenshot: ${screenshotPath}`);

  await browser.close();

  if (!allPassed) {
    console.error('\nOne or more route protection tests failed!');
    process.exit(1);
  }

  console.log('\nAll authentication protection & refresh tests PASSED perfectly!');
}

testAuthProtection().catch(err => {
  console.error('Test script error:', err);
  process.exit(1);
});
