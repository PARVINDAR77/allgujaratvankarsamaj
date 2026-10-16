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
      '.jpeg': 'image/jpeg',
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

server.listen(8768, async () => {
  console.log('Serving Flutter Web on http://localhost:8768');
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 412, height: 915 });

    console.log('Navigating to http://localhost:8768/#/education ...');
    await page.goto('http://localhost:8768/#/education', {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    await new Promise(r => setTimeout(r, 5000));

    // Scroll down to view Box 5
    await page.mouse.move(200, 500);
    for (let i = 0; i < 10; i++) {
      await page.mouse.wheel({ deltaY: 300 });
      await new Promise(r => setTimeout(r, 150));
    }
    await new Promise(r => setTimeout(r, 1000));

    const shotPath = path.join(__dirname, 'education_box5_preview.png');
    await page.screenshot({ path: shotPath });
    console.log('Screenshot saved to:', shotPath);

    await browser.close();
    server.close();
    console.log('Test completed successfully.');
  } catch (err) {
    console.error('Error generating preview:', err);
    server.close();
  }
});
