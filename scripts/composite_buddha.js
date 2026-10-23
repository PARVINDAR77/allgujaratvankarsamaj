const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function createComposites() {
  console.log('Creating seamless Buddha composites on the given hero image...');
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();

  const heroPath = 'C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b/.user_uploaded/media_1792667125934.png';
  const buddhaPath = path.resolve(__dirname, '../application/assets/images/buddha_golden_statue_transparent.png');

  const heroB64 = fs.readFileSync(heroPath).toString('base64');
  const buddhaB64 = fs.readFileSync(buddhaPath).toString('base64');

  // Variation 1: Buddha on the Left of the hero section (spiritual guardian)
  const resultLeft = await page.evaluate(async (hB64, bB64) => {
    return new Promise((resolve) => {
      const heroImg = new Image();
      const budImg = new Image();
      let loaded = 0;
      const onDone = () => {
        loaded++;
        if (loaded < 2) return;

        const w = heroImg.width;
        const h = heroImg.height;
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');

        // Draw original hero background
        ctx.drawImage(heroImg, 0, 0);

        // Draw Buddha on left side
        // Scale Buddha to fit nicely within height
        const budH = h * 0.78; // e.g. ~300px
        const budW = budH * (budImg.width / budImg.height);
        const budX = 18;
        const budY = (h - budH) / 2 + 10;

        // 1. Soft radiant golden aura behind Buddha
        const glow = ctx.createRadialGradient(
          budX + budW * 0.5, budY + budH * 0.4, 10,
          budX + budW * 0.5, budY + budH * 0.4, budW * 0.85
        );
        glow.addColorStop(0, 'rgba(255, 223, 122, 0.45)');
        glow.addColorStop(0.5, 'rgba(214, 163, 74, 0.2)');
        glow.addColorStop(1, 'rgba(250, 248, 245, 0)');

        ctx.fillStyle = glow;
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, budY + budH * 0.4, budW * 0.85, 0, Math.PI * 2);
        ctx.fill();

        // 2. Soft contact shadow under lotus base
        const shadow = ctx.createRadialGradient(
          budX + budW * 0.5, budY + budH - 4, 10,
          budX + budW * 0.5, budY + budH - 4, budW * 0.5
        );
        shadow.addColorStop(0, 'rgba(16, 27, 54, 0.25)');
        shadow.addColorStop(0.6, 'rgba(16, 27, 54, 0.08)');
        shadow.addColorStop(1, 'rgba(16, 27, 54, 0)');

        ctx.fillStyle = shadow;
        ctx.save();
        ctx.scale(1, 0.28);
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, (budY + budH - 4) / 0.28, budW * 0.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // 3. Draw Buddha statue
        ctx.drawImage(budImg, budX, budY, budW, budH);

        resolve(canvas.toDataURL('image/png').split(',')[1]);
      };

      heroImg.onload = onDone;
      budImg.onload = onDone;
      heroImg.src = 'data:image/png;base64,' + hB64;
      budImg.src = 'data:image/png;base64,' + bB64;
    });
  }, heroB64, buddhaB64);

  const outLeft = path.resolve(__dirname, '../buddha_hero_composite_left.png');
  fs.writeFileSync(outLeft, Buffer.from(resultLeft, 'base64'));
  console.log('Saved left composite to:', outLeft);

  // Variation 2: Extended canvas (1200x382) with Buddha on the left and re-centered text
  const resultExtended = await page.evaluate(async (hB64, bB64) => {
    return new Promise((resolve) => {
      const heroImg = new Image();
      const budImg = new Image();
      let loaded = 0;
      const onDone = () => {
        loaded++;
        if (loaded < 2) return;

        const origW = heroImg.width;
        const origH = heroImg.height;
        // Expand canvas width to give Buddha a sacred throne space on the left
        const newW = origW + 180;
        const newH = origH;
        const canvas = document.createElement('canvas');
        canvas.width = newW;
        canvas.height = newH;
        const ctx = canvas.getContext('2d');

        // Fill background with exact hero gradient
        const bgGrad = ctx.createLinearGradient(0, 0, 0, newH);
        bgGrad.addColorStop(0, '#FFFFFF');
        bgGrad.addColorStop(0.5, '#FAF8F5');
        bgGrad.addColorStop(1, '#F6F2E9');
        ctx.fillStyle = bgGrad;
        ctx.fillRect(0, 0, newW, newH);

        // Draw original hero shifted right by 160px
        ctx.drawImage(heroImg, 160, 0);

        // Draw Buddha on far left with aura
        const budH = newH * 0.82;
        const budW = budH * (budImg.width / budImg.height);
        const budX = 25;
        const budY = (newH - budH) / 2 + 10;

        // Radiant glow
        const glow = ctx.createRadialGradient(
          budX + budW * 0.5, budY + budH * 0.4, 10,
          budX + budW * 0.5, budY + budH * 0.4, budW * 0.9
        );
        glow.addColorStop(0, 'rgba(255, 223, 122, 0.5)');
        glow.addColorStop(0.5, 'rgba(214, 163, 74, 0.25)');
        glow.addColorStop(1, 'rgba(250, 248, 245, 0)');
        ctx.fillStyle = glow;
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, budY + budH * 0.4, budW * 0.9, 0, Math.PI * 2);
        ctx.fill();

        // Contact shadow
        ctx.save();
        ctx.scale(1, 0.26);
        const shadow = ctx.createRadialGradient(
          budX + budW * 0.5, (budY + budH - 4) / 0.26, 10,
          budX + budW * 0.5, (budY + budH - 4) / 0.26, budW * 0.5
        );
        shadow.addColorStop(0, 'rgba(16, 27, 54, 0.3)');
        shadow.addColorStop(0.6, 'rgba(16, 27, 54, 0.1)');
        shadow.addColorStop(1, 'rgba(16, 27, 54, 0)');
        ctx.fillStyle = shadow;
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, (budY + budH - 4) / 0.26, budW * 0.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Draw Buddha
        ctx.drawImage(budImg, budX, budY, budW, budH);

        resolve(canvas.toDataURL('image/png').split(',')[1]);
      };

      heroImg.onload = onDone;
      budImg.onload = onDone;
      heroImg.src = 'data:image/png;base64,' + hB64;
      budImg.src = 'data:image/png;base64,' + bB64;
    });
  }, heroB64, buddhaB64);

  const outExt = path.resolve(__dirname, '../buddha_hero_composite_extended.png');
  fs.writeFileSync(outExt, Buffer.from(resultExtended, 'base64'));
  console.log('Saved extended composite to:', outExt);

  await browser.close();
}

createComposites().catch(err => {
  console.error('Composite creation failed:', err);
  process.exit(1);
});
