const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  const wingB64 = fs.readFileSync('application/assets/images/wing_teal_aperture.png').toString('base64');
  
  const configs = [
    { left: 30.5, top: 29.5, size: 59 },
    { left: 30.8, top: 29.8, size: 58.4 },
    { left: 31.0, top: 30.0, size: 58 },
    { left: 30.5, top: 30.0, size: 59 },
  ];

  for (let idx = 0; idx < configs.length; idx++) {
    const c = configs[idx];
    await page.setContent(`
      <!DOCTYPE html>
      <html>
      <body style="margin:0; background:#00241B; padding:20px;">
        <div style="position:relative; width:110px; height:122px; background:#FAF5E8; border-radius:15px; overflow:hidden;">
          <img src="data:image/png;base64,${wingB64}" style="position:absolute; left:0; top:0; width:110px; height:122px;" />
          <div style="position:absolute; left:${c.left}px; top:${c.top}px; width:${c.size}px; height:${c.size}px; border-radius:50%; border:2px solid red; box-sizing:border-box;"></div>
        </div>
      </body>
      </html>
    `);
    await page.screenshot({ path: 'test_ring_' + idx + '.png' });
    console.log('Saved test_ring_' + idx + '.png for config', c);
  }
  await browser.close();
})();
