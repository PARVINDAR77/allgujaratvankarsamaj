const puppeteer = require('puppeteer');
const path = require('path');

async function testScroll() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1080 });
  await page.goto('http://localhost:5055/#/main-poster', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));

  // Screenshot 1: Hero & Cards top
  await page.screenshot({ path: path.resolve(__dirname, '../shot_1_hero_cards.png') });

  await page.mouse.move(960, 540);

  // Scroll down to Services
  await page.mouse.wheel({ deltaY: 850 });
  await new Promise(r => setTimeout(r, 1200));
  await page.screenshot({ path: path.resolve(__dirname, '../shot_2_services.png') });

  // Scroll down to Gujarat Development
  await page.mouse.wheel({ deltaY: 1000 });
  await new Promise(r => setTimeout(r, 1200));
  await page.screenshot({ path: path.resolve(__dirname, '../shot_3_development.png') });

  // Scroll down to Portals & Values
  await page.mouse.wheel({ deltaY: 1000 });
  await new Promise(r => setTimeout(r, 1200));
  await page.screenshot({ path: path.resolve(__dirname, '../shot_4_portals_values.png') });

  // Scroll down to Footer
  await page.mouse.wheel({ deltaY: 1200 });
  await new Promise(r => setTimeout(r, 1200));
  await page.screenshot({ path: path.resolve(__dirname, '../shot_5_footer.png') });

  await browser.close();
  console.log('Scroll screenshots captured!');
}

testScroll().catch(console.error);
