const puppeteer = require('puppeteer');
const http = require('http');
const fs = require('fs');
const path = require('path');

const webDir = path.join(__dirname, 'application', 'build', 'web');

// Simple static server
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
      '.svg': 'image/svg+xml'
    }[ext] || 'application/octet-stream';
    
    res.writeHead(200, { 'Content-Type': contentType });
    fs.createReadStream(filePath).pipe(res);
  } else {
    // SPA fallback
    const indexPath = path.join(webDir, 'index.html');
    res.writeHead(200, { 'Content-Type': 'text/html' });
    fs.createReadStream(indexPath).pipe(res);
  }
});

server.listen(8765, async () => {
  console.log('Serving on http://localhost:8765');
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 412, height: 915 });

    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    page.on('requestfailed', request => {
      console.log('PAGE REQ FAILED:', request.url(), request.failure()?.errorText);
    });
    page.on('response', response => {
      if (response.url().includes('pavan-prernadata')) {
        console.log('API RESPONSE:', response.status(), response.url());
      }
    });

    console.log('Opening local build at http://localhost:8765/#/pavan-prernadata ...');
    await page.goto('http://localhost:8765/#/pavan-prernadata', {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    console.log('Waiting 8s for Flutter rendering...');
    await new Promise(r => setTimeout(r, 8000));

    const outPath = path.join(__dirname, 'local_pavan_fullscreen.png');
    await page.screenshot({ path: outPath });
    console.log('Saved screenshot to:', outPath);

    await browser.close();
  } catch (err) {
    console.error('Error during preview:', err);
  } finally {
    server.close();
    process.exit(0);
  }
});
