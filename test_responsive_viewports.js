const puppeteer = require('puppeteer');
const http = require('http');
const fs = require('fs');
const path = require('path');

const webDir = path.join(__dirname, 'application', 'build', 'web');

const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath === '/') reqPath = '/index.html';
  const filePath = path.join(webDir, reqPath);

  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    const ext = path.extname(filePath);
    const contentType = {
      '.html': 'text/html',
      '.js': 'application/javascript',
      '.css': 'text/css',
      '.json': 'application/json',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.wasm': 'application/wasm',
      '.svg': 'image/svg+xml'
    }[ext] || 'application/octet-stream';

    res.writeHead(200, { 'Content-Type': contentType });
    fs.createReadStream(filePath).pipe(res);
  } else {
    const indexPath = path.join(webDir, 'index.html');
    res.writeHead(200, { 'Content-Type': 'text/html' });
    fs.createReadStream(indexPath).pipe(res);
  }
});

const viewports = [
  { name: 'mobile_375', width: 375, height: 812 },
  { name: 'mobile_414', width: 414, height: 896 },
  { name: 'tablet_768', width: 768, height: 1024 },
  { name: 'tablet_820', width: 820, height: 1180 },
  { name: 'desktop_1280', width: 1280, height: 800 },
  { name: 'desktop_1920', width: 1920, height: 1080 }
];

const results = [];

server.listen(8770, async () => {
  console.log('Serving on http://localhost:8770');
  let browser;
  try {
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();

    page.on('console', msg => {
      const txt = msg.text();
      if (txt.includes('Error') || txt.includes('Exception')) {
        console.log('BROWSER_CONSOLE_ERR:', txt);
      }
    });

    page.on('pageerror', err => {
      console.log('BROWSER_PAGE_ERR:', err.toString());
    });

    for (const vp of viewports) {
      console.log(`\n=== Testing Viewport: ${vp.name} (${vp.width}x${vp.height}) ===`);
      await page.setViewport({ width: vp.width, height: vp.height });

      // Test 1: Login / Root
      console.log(`Navigating to http://localhost:8770/ ...`);
      await page.goto('http://localhost:8770/', { waitUntil: 'networkidle0', timeout: 30000 });
      await new Promise(r => setTimeout(r, 6000));

      const overflow = await page.evaluate(() => {
        return {
          scrollWidth: document.body.scrollWidth,
          clientWidth: window.innerWidth,
          hasHorizontalOverflow: document.body.scrollWidth > window.innerWidth
        };
      });

      console.log(`Viewport ${vp.width}px overflow test:`, overflow);

      const shotPath = path.join(__dirname, `audit_${vp.name}_login.png`);
      await page.screenshot({ path: shotPath });
      console.log(`Saved screenshot: ${shotPath}`);

      // Test 2: Register
      await page.goto('http://localhost:8770/#/register', { waitUntil: 'networkidle0', timeout: 30000 });
      await new Promise(r => setTimeout(r, 4000));
      const regShotPath = path.join(__dirname, `audit_${vp.name}_register.png`);
      await page.screenshot({ path: regShotPath });
      console.log(`Saved screenshot: ${regShotPath}`);

      results.push({
        viewport: `${vp.width}x${vp.height}`,
        name: vp.name,
        horizontalOverflow: overflow.hasHorizontalOverflow,
        status: !overflow.hasHorizontalOverflow ? 'PASS' : 'FAIL'
      });
    }

    console.log('\n=== RESPONSIVE AUDIT RESULTS ===');
    console.log(JSON.stringify(results, null, 2));

  } catch (err) {
    console.error('Audit failed with error:', err);
  } finally {
    if (browser) await browser.close();
    server.close();
    process.exit(0);
  }
});
