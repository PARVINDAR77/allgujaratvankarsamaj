const puppeteer = require('puppeteer');
const http = require('http');
const fs = require('fs');
const path = require('path');

const outDir = path.join(__dirname, 'next-nest', 'frontend', 'out');

const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath.endsWith('/')) reqPath += 'index.html';
  if (!path.extname(reqPath)) reqPath += '.html';
  let filePath = path.join(outDir, reqPath);
  
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
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(8769, async () => {
  console.log('Serving Admin Panel on http://localhost:8769');
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 1440, height: 900 });

    await page.evaluateOnNewDocument(() => {
      localStorage.setItem('adminUser', JSON.stringify({ name: 'Admin Officer', role: 'SUPER_ADMIN', email: 'admin@vankarsamaj.com' }));
      localStorage.setItem('adminToken', 'mock_token');
    });

    await page.goto('http://localhost:8769/admin/education/', {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    await new Promise(r => setTimeout(r, 2000));

    // Scroll down to see Box 4 and Box 5
    await page.evaluate(() => window.scrollBy(0, 1100));
    await new Promise(r => setTimeout(r, 1000));

    const shotPath = path.join(__dirname, 'admin_education_box5_preview.png');
    await page.screenshot({ path: shotPath });
    console.log('Admin Screenshot saved to:', shotPath);

    await browser.close();
    server.close();
    console.log('Admin test completed.');
  } catch (err) {
    console.error('Error generating preview:', err);
    server.close();
  }
});
