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

server.listen(8766, async () => {
  console.log('Serving on http://localhost:8766');
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 412, height: 915 });

    console.log('Opening local build at http://localhost:8766/#/family-details ...');
    await page.goto('http://localhost:8766/#/family-details', {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Wait 5 seconds for flutter web and riverpod to load mock/api data
    await new Promise(r => setTimeout(r, 6000));

    const shotPath = path.join(__dirname, 'family_details_preview.png');
    await page.screenshot({ path: shotPath, fullPage: false });
    console.log('Screenshot saved to:', shotPath);

    // Scroll down to the bottom to verify the bottom trim
    await page.mouse.move(200, 500);
    for (let i = 0; i < 25; i++) {
      await page.mouse.wheel({ deltaY: 800 });
      await new Promise(r => setTimeout(r, 60));
    }
    await new Promise(r => setTimeout(r, 1500));
    const bottomPath = path.join(__dirname, 'family_details_bottom_preview.png');
    await page.screenshot({ path: bottomPath, fullPage: false });
    console.log('Bottom screenshot saved to:', bottomPath);

    await browser.close();
    server.close();
    process.exit(0);
  } catch (err) {
    console.error('Error during preview:', err);
    server.close();
    process.exit(1);
  }
});
