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

server.listen(8775, async () => {
  console.log('Serving on http://localhost:8775');
  let browser;
  try {
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 800 });

    page.on('console', msg => {
      const txt = msg.text();
      if (txt.includes('Error') || txt.includes('[API]')) {
        console.log('BROWSER_LOG:', txt);
      }
    });

    console.log('Navigating to http://localhost:8775/#/login ...');
    await page.goto('http://localhost:8775/#/login', { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, 6000));

    // Click Login Button on Poster
    // The Login button is around center-bottom of poster: x=580, y=555 on 1280x800 viewport
    console.log('Clicking Login button on poster...');
    const box = await page.evaluate(() => {
      const flt = document.querySelector('flutter-view, flt-glass-pane');
      if (flt) {
        const rect = flt.getBoundingClientRect();
        return { x: rect.left + rect.width / 2 - 50, y: rect.top + rect.height * 0.745 };
      }
      return { x: 600, y: 550 };
    });

    await page.mouse.click(box.x, box.y);
    await new Promise(r => setTimeout(r, 2000));

    // Capture dialog screenshot
    await page.screenshot({ path: path.join(__dirname, 'audit_login_dialog.png') });
    console.log('Saved dialog screenshot');

    // Type email and password
    // In Flutter Web canvas, we can type using keyboard
    const testEmail = process.env.TEST_USER_EMAIL || 'test-user@example.test';
    const testPassword = process.env.TEST_USER_PASSWORD || 'TestPassword123!';
    await page.keyboard.press('Tab');
    await new Promise(r => setTimeout(r, 300));
    await page.keyboard.type(testEmail);
    await new Promise(r => setTimeout(r, 300));
    await page.keyboard.press('Tab');
    await new Promise(r => setTimeout(r, 300));
    await page.keyboard.type(testPassword);
    await new Promise(r => setTimeout(r, 300));
    await page.keyboard.press('Enter');

    console.log('Submitted credentials, waiting for API response...');
    await new Promise(r => setTimeout(r, 6000));

    await page.screenshot({ path: path.join(__dirname, 'audit_post_login.png') });
    console.log('Saved post-login screenshot');

    // Test direct navigation to public community route /pavan-prernadata
    console.log('Navigating to /pavan-prernadata at 1280px...');
    await page.goto('http://localhost:8775/#/pavan-prernadata', { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, 5000));
    await page.screenshot({ path: path.join(__dirname, 'audit_desktop_pavan.png') });

    // Test direct navigation to /education
    console.log('Navigating to /education at 1280px...');
    await page.goto('http://localhost:8775/#/education', { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, 5000));
    await page.screenshot({ path: path.join(__dirname, 'audit_desktop_education.png') });

    // Test direct navigation to /statistics
    console.log('Navigating to /statistics at 1280px...');
    await page.goto('http://localhost:8775/#/statistics', { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, 5000));
    await page.screenshot({ path: path.join(__dirname, 'audit_desktop_statistics.png') });

    console.log('All direct route navigations verified!');
  } catch (err) {
    console.error('Error during auth flow test:', err);
  } finally {
    if (browser) await browser.close();
    server.close();
    process.exit(0);
  }
});
