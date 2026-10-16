const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const wingB64 = fs.readFileSync('application/assets/images/wing_teal_aperture.png').toString('base64');
  
  await page.setContent(`
    <!DOCTYPE html>
    <html>
    <body style="margin:0; background:#00241B; padding:20px;">
      <div style="position:relative; width:110px; height:122px; background:#FAF5E8; border-radius:15px; overflow:hidden;">
        <img src="data:image/png;base64,${wingB64}" style="position:absolute; left:0; top:0; width:110px; height:122px;" />
        <div style="position:absolute; left:29.5px; top:28.5px; width:61px; height:61px; border-radius:50%; border:2px solid #D4AF37; background:url('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100') center/cover; box-sizing:border-box;"></div>
      </div>
    </body>
    </html>
  `);
  await page.screenshot({ path: 'test_photo_snug.png' });
  console.log('Saved test_photo_snug.png');
  await browser.close();
})();
