const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function run() {
  console.log('Generating pixel-perfect Buddha composites...');
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();

  const heroPath = 'C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b/.user_uploaded/media_1792667125934.png';
  const buddhaPath = path.resolve(__dirname, '../application/assets/images/buddha_golden_statue_transparent.png');

  const heroB64 = fs.readFileSync(heroPath).toString('base64');
  const buddhaB64 = fs.readFileSync(buddhaPath).toString('base64');

  // Composite 1: Exact 1024x382 dimensions matching user's uploaded image
  // Layout in 1024x382:
  // - Clean background matching exact hero gradient (#FFFFFF -> #FAF8F5 -> #F6F2E9)
  // - Top-left & top-right corner mandala watermarks
  // - Left (x: 20 to 225): Majestic Buddha statue (height: 295px) with soft golden aura & lotus shadow
  // - Center (x: 235 to 640): Community title, slogan, subtitle, CTAs & trust badges
  // - Right (x: 670 to 990): Matrimony card (width: 310px, height: 310px) with gold border & glow
  const composite1024 = await page.evaluate(async (hB64, bB64) => {
    return new Promise((resolve) => {
      const heroImg = new Image();
      const budImg = new Image();
      let loaded = 0;
      const onDone = () => {
        loaded++;
        if (loaded < 2) return;

        const w = 1024;
        const h = 382;
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');

        // 1. Hero background gradient
        const bgGrad = ctx.createLinearGradient(0, 0, 0, h);
        bgGrad.addColorStop(0, '#FFFFFF');
        bgGrad.addColorStop(0.5, '#FAF8F5');
        bgGrad.addColorStop(1, '#F6F2E9');
        ctx.fillStyle = bgGrad;
        ctx.fillRect(0, 0, w, h);

        // 2. Extract corner mandalas from heroImg
        // Top-left mandala (first 100x100)
        ctx.drawImage(heroImg, 0, 0, 120, 120, 0, 0, 120, 120);
        // Top-right mandala
        ctx.drawImage(heroImg, heroImg.width - 120, 0, 120, 120, w - 120, 0, 120, 120);

        // 3. Extract Matrimonial Card from heroImg (right side of original)
        // Original card is around x: 560, y: 38, width: 332, height: 332
        const cardOrigX = 560;
        const cardOrigY = 38;
        const cardOrigW = 334;
        const cardOrigH = 334;

        // Draw Matrimony card on right side of new canvas (x: 710, y: 40, w: 300, h: 300)
        const targetCardW = 302;
        const targetCardH = 302;
        const targetCardX = w - targetCardW - 16;
        const targetCardY = (h - targetCardH) / 2;
        ctx.drawImage(heroImg, cardOrigX, cardOrigY, cardOrigW, cardOrigH, targetCardX, targetCardY, targetCardW, targetCardH);

        // 4. Extract Left Text content from heroImg (badge, heading, description, buttons, badges)
        // In original heroImg, text is between x: 108 and x: 530, y: 40 to 320
        const textOrigX = 108;
        const textOrigY = 40;
        const textOrigW = 428;
        const textOrigH = 290;

        // Draw Text block in center (x: 270, y: 46)
        const targetTextX = 270;
        const targetTextY = (h - textOrigH) / 2;
        ctx.drawImage(heroImg, textOrigX, textOrigY, textOrigW, textOrigH, targetTextX, targetTextY, textOrigW, textOrigH);

        // 5. Place Lord Buddha Statue on Left (x: 14, height: 290)
        const budH = 290;
        const budW = budH * (budImg.width / budImg.height); // ~241px
        const budX = 14;
        const budY = (h - budH) / 2 + 8;

        // Subtle sacred golden aura
        const aura = ctx.createRadialGradient(
          budX + budW * 0.5, budY + budH * 0.38, 15,
          budX + budW * 0.5, budY + budH * 0.38, budW * 0.8
        );
        aura.addColorStop(0, 'rgba(255, 223, 122, 0.5)');
        aura.addColorStop(0.45, 'rgba(214, 163, 74, 0.22)');
        aura.addColorStop(1, 'rgba(250, 248, 245, 0)');
        ctx.fillStyle = aura;
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, budY + budH * 0.38, budW * 0.8, 0, Math.PI * 2);
        ctx.fill();

        // Soft grounding contact shadow under lotus base
        ctx.save();
        ctx.scale(1, 0.28);
        const groundShadow = ctx.createRadialGradient(
          budX + budW * 0.5, (budY + budH - 4) / 0.28, 10,
          budX + budW * 0.5, (budY + budH - 4) / 0.28, budW * 0.48
        );
        groundShadow.addColorStop(0, 'rgba(16, 27, 54, 0.35)');
        groundShadow.addColorStop(0.5, 'rgba(16, 27, 54, 0.12)');
        groundShadow.addColorStop(1, 'rgba(16, 27, 54, 0)');
        ctx.fillStyle = groundShadow;
        ctx.beginPath();
        ctx.arc(budX + budW * 0.5, (budY + budH - 4) / 0.28, budW * 0.48, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();

        // Draw Buddha statue cleanly
        ctx.drawImage(budImg, budX, budY, budW, budH);

        // Gold subtle accent under Buddha
        ctx.font = 'bold 9.5px sans-serif';
        ctx.fillStyle = '#A4143D';
        ctx.textAlign = 'center';
        ctx.fillText('પાવન પ્રેરણાદાતા • ભગવાન બુદ્ધ', budX + budW * 0.5, budY + budH + 14);

        resolve(canvas.toDataURL('image/png').split(',')[1]);
      };

      heroImg.onload = onDone;
      budImg.onload = onDone;
      heroImg.src = 'data:image/png;base64,' + hB64;
      budImg.src = 'data:image/png;base64,' + bB64;
    });
  }, heroB64, buddhaB64);

  const out1024Path = path.resolve(__dirname, '../buddha_set_in_given_hero_image.png');
  fs.writeFileSync(out1024Path, Buffer.from(composite1024, 'base64'));
  console.log('Saved exact 1024x382 Buddha composite to:', out1024Path);

  // Copy to artifact directory so it's directly accessible as an artifact
  const artifactDir = 'C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b';
  const artifactPath = path.join(artifactDir, 'buddha_set_in_given_hero_image.png');
  fs.writeFileSync(artifactPath, Buffer.from(composite1024, 'base64'));
  console.log('Saved to artifact directory:', artifactPath);

  await browser.close();
}

run().catch(err => {
  console.error('Error running composite generation:', err);
  process.exit(1);
});
