const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const wingB64 = fs.readFileSync('application/assets/images/wing_teal_aperture.png').toString('base64');
  
  await page.setContent(`
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"></head>
    <body style="margin:0; background:#00241B; padding:20px;">
      <div style="position:relative; width:372px; height:122px; background:#FAF5E8; border-radius:15.6px; overflow:hidden; border:2px solid #D4AF37;">
        <img src="data:image/png;base64,${wingB64}" style="position:absolute; left:0; top:0; width:115px; height:122px;" />
        <div style="position:absolute; left:33.8px; top:22.9px; width:58px; height:58px; border-radius:50%; background:url('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100') center/cover; box-sizing:border-box;"></div>
      </div>
    </body>
    </html>
  `);
  
  await page.screenshot({ path: 'test_photo_perfect_match.png' });
  console.log('Saved test_photo_perfect_match.png');
  await browser.close();
})();
