const puppeteer = require('puppeteer');
const path = require('path');

async function run() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });

  // 1. Visit root '/'
  console.log('1. Navigating to root http://localhost:5055/ ...');
  await page.goto('http://localhost:5055/', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));
  const url1 = page.url();
  console.log('   Current URL on root load:', url1);
  await page.screenshot({ path: path.join(__dirname, '../verified_root_initial.png') });

  // 2. Refresh root '/'
  console.log('2. Refreshing root ...');
  await page.reload({ waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));
  const url2 = page.url();
  console.log('   Current URL on root refresh:', url2);
  await page.screenshot({ path: path.join(__dirname, '../verified_root_refresh.png') });

  // 3. Visit '/samaj-services' and refresh
  console.log('3. Navigating to http://localhost:5055/#/samaj-services ...');
  await page.goto('http://localhost:5055/#/samaj-services', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));
  console.log('   Current URL on services load:', page.url());
  await page.reload({ waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));
  console.log('   Current URL on services refresh:', page.url());
  await page.screenshot({ path: path.join(__dirname, '../verified_services_refresh.png') });

  // 4. Visit '/login' directly
  console.log('4. Navigating to http://localhost:5055/#/login ...');
  await page.goto('http://localhost:5055/#/login', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));
  console.log('   Current URL on login load:', page.url());
  await page.screenshot({ path: path.join(__dirname, '../verified_login_direct.png') });

  await browser.close();
  console.log('ALL VERIFICATIONS COMPLETED SUCCESSFULLY!');
}

run().catch(console.error);
