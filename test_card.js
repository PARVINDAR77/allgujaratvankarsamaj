const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const card1B64 = fs.readFileSync('pure_card1.png').toString('base64');
  
  await page.setContent(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { margin:0; background:#00241B; padding:20px; font-family:sans-serif; }
        .card {
          width: 372px;
          height: 86px;
          border-radius: 16px;
          overflow: hidden;
          position: relative;
          box-shadow: 0 4px 10px rgba(0,0,0,0.4);
        }
        .card img {
          width: 100%;
          height: 100%;
          display: block;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <img src="data:image/png;base64,${card1B64}" />
      </div>
    </body>
    </html>
  `);
  
  await page.screenshot({ path: 'test_full_card1.png' });
  console.log('Saved test_full_card1.png');
  await browser.close();
})();
