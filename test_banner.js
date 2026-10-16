const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  const b64 = fs.readFileSync('mockup_banner.png').toString('base64');
  
  await page.setContent(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { margin: 0; background: #00241B; padding: 20px; font-family: sans-serif; }
        .banner-box {
          position: relative;
          width: 372px;
          height: 81px;
          border-radius: 16px;
          overflow: hidden;
        }
        .bg-img {
          width: 100%;
          height: 100%;
          display: block;
        }
        .live-pill {
          position: absolute;
          right: 14px;
          top: 23px;
          background: linear-gradient(180deg, #005A43 0%, #00362A 100%);
          border: 1.8px solid #FFD700;
          border-radius: 20px;
          padding: 5px 10px;
          display: flex;
          align-items: center;
          gap: 5px;
          box-shadow: 0 0 6px rgba(255, 215, 0, 0.4);
          color: white;
          font-weight: bold;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="banner-box">
        <img class="bg-img" src="data:image/png;base64,${b64}" />
        <div class="live-pill">
          <span style="color:#FFD700;">👥</span>
          <span>20 પરિવારો</span>
        </div>
      </div>
    </body>
    </html>
  `);

  await page.screenshot({ path: 'test_banner_composite.png' });
  console.log('Saved test_banner_composite.png');
  await browser.close();
})();
