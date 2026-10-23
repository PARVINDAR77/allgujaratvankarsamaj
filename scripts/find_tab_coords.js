const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1080 });

  await page.goto('http://localhost:5055/#/samaj-services', { waitUntil: 'networkidle2', timeout: 30000 });
  await new Promise(r => setTimeout(r, 6000));

  await page.evaluate(() => {
    function mark(x, y, color) {
      const dot = document.createElement('div');
      dot.style.position = 'fixed';
      dot.style.left = (x - 8) + 'px';
      dot.style.top = (y - 8) + 'px';
      dot.style.width = '16px';
      dot.style.height = '16px';
      dot.style.borderRadius = '50%';
      dot.style.background = color;
      dot.style.border = '2px solid white';
      dot.style.zIndex = '99999999';
      dot.style.pointerEvents = 'none';
      document.body.appendChild(dot);
    }
    mark(950, 975, 'orange');
    mark(1050, 975, 'yellow');
    mark(1150, 975, 'cyan');
  });

  // Now click at (1050, 975)
  console.log('Clicking at (1050, 975)...');
  await page.mouse.click(1050, 975);
  await new Promise(r => setTimeout(r, 2500));

  await page.screenshot({ path: 'screenshot_dots_tabs.png' });
  console.log('Saved screenshot_dots_tabs.png');

  await browser.close();
})();
