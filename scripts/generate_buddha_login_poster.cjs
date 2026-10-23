const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function generateBuddhaLoginPoster() {
  console.log('Generating full edge-to-edge Buddha Sacred Login Poster...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  const buddhaImgPath = path.resolve(__dirname, '../application/assets/images/buddha_meditation_sacred.jpg');
  const logoImgPath = path.resolve(__dirname, '../application/assets/images/matrimony_couple_logo.png');

  const buddhaB64 = fs.readFileSync(buddhaImgPath).toString('base64');
  const logoB64 = fs.readFileSync(logoImgPath).toString('base64');

  const width = 975;
  const height = 865;

  await page.setViewport({ width, height, deviceScaleFactor: 2 });

  const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:ital,wght@0,600;0,700;1,400&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      width: ${width}px;
      height: ${height}px;
      overflow: hidden;
      font-family: 'Plus Jakarta Sans', sans-serif;
      position: relative;
    }
    
    /* 100% Full edge-to-edge background - continuous sacred painting */
    .bg-image {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      object-fit: cover;
      object-position: 62% center; /* Gives Lord Buddha optimal breathing room while keeping full painting */
      z-index: 1;
    }

    /* Soft natural ambient luminous wash on left so forest foliage shows through while text remains 100% readable */
    .ambient-soft-wash {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, 
        rgba(255, 255, 255, 0.90) 0%, 
        rgba(255, 255, 255, 0.82) 26%, 
        rgba(255, 255, 255, 0.52) 44%, 
        rgba(255, 255, 255, 0.15) 58%, 
        rgba(255, 255, 255, 0.0) 72%
      );
      z-index: 2;
      pointer-events: none;
    }

    /* Content Container */
    .content-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: 4;
      padding: 40px 48px;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
    }

    /* Top Brand Header */
    .brand-header {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 46px;
    }

    .brand-logo-wrapper {
      width: 66px;
      height: 66px;
      border-radius: 50%;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #FFFFFF;
      box-shadow: 0 4px 14px rgba(132, 22, 43, 0.25);
      flex-shrink: 0;
    }

    .brand-logo {
      width: 66px;
      height: 66px;
      object-fit: cover;
    }

    .brand-text-col {
      display: flex;
      flex-direction: column;
    }

    .brand-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 26px;
      font-weight: 700;
      color: #7E1128;
      letter-spacing: -0.2px;
      line-height: 1.15;
      text-shadow: 0 1px 3px rgba(255, 255, 255, 0.8);
    }

    .brand-matrimony {
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 4.8px;
      color: #8E1530;
      margin-top: 3px;
      text-transform: uppercase;
      text-align: center;
    }

    .brand-slogan {
      font-size: 11px;
      font-weight: 600;
      color: #3E3E3E;
      margin-top: 5px;
      letter-spacing: 0.8px;
      text-align: center;
    }

    /* Hero Headline */
    .headline-section {
      margin-bottom: 36px;
      max-width: 440px;
    }

    .headline-primary {
      font-size: 38px;
      font-weight: 800;
      line-height: 1.12;
      color: #1A1E21;
      letter-spacing: -0.6px;
      text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
    }

    .headline-accent {
      color: #8E1530;
      display: block;
      font-size: 44px;
      letter-spacing: -0.5px;
    }

    .headline-desc {
      margin-top: 14px;
      font-size: 14.5px;
      line-height: 1.5;
      color: #2D3134;
      font-weight: 600;
      max-width: 360px;
      text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
    }

    /* Trust Badges */
    .badges-list {
      display: flex;
      flex-direction: column;
      gap: 18px;
      max-width: 360px;
    }

    .badge-item {
      display: flex;
      align-items: center;
      gap: 14px;
    }

    .badge-icon-box {
      width: 42px;
      height: 42px;
      border-radius: 50%;
      background: #7E1128;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 12px rgba(126, 17, 40, 0.35);
      flex-shrink: 0;
    }

    .badge-icon-svg {
      width: 21px;
      height: 21px;
      fill: #FFFFFF;
    }

    .badge-text {
      display: flex;
      flex-direction: column;
    }

    .badge-title {
      font-size: 14.5px;
      font-weight: 700;
      color: #1A1E21;
      text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
    }

    .badge-sub {
      font-size: 12.5px;
      font-weight: 600;
      color: #3E4347;
      margin-top: 1px;
      text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
    }

    /* Bottom-Left Maroon Diagonal Ribbon */
    .diagonal-ribbon {
      position: absolute;
      bottom: 0;
      left: 0;
      width: 440px;
      height: 240px;
      z-index: 5;
      pointer-events: none;
    }

    .ribbon-svg {
      width: 100%;
      height: 100%;
      position: absolute;
      bottom: 0;
      left: 0;
      filter: drop-shadow(4px -4px 14px rgba(60, 8, 18, 0.45));
    }

    .ribbon-text-wrapper {
      position: absolute;
      bottom: 22px;
      left: 20px;
      z-index: 6;
      transform: rotate(-18deg);
      transform-origin: left bottom;
      display: flex;
      flex-direction: column;
    }

    .ribbon-line-1 {
      font-family: 'Great Vibes', cursive;
      font-size: 36px;
      color: #FFFFFF;
      font-weight: 400;
      letter-spacing: 0.5px;
      line-height: 1.1;
      text-shadow: 0 2px 5px rgba(0, 0, 0, 0.4);
    }

    .ribbon-line-2 {
      font-family: 'Great Vibes', cursive;
      font-size: 40px;
      color: #FFFFFF;
      font-weight: 400;
      letter-spacing: 0.5px;
      line-height: 1.05;
      margin-left: 24px;
      text-shadow: 0 2px 5px rgba(0, 0, 0, 0.4);
    }

    .ribbon-flourish {
      width: 130px;
      height: 2.2px;
      background: rgba(255, 255, 255, 0.85);
      border-radius: 2px;
      margin-top: 2px;
      margin-left: 26px;
      position: relative;
    }
    .ribbon-flourish::after {
      content: '';
      position: absolute;
      right: -3px;
      top: -2px;
      width: 6px;
      height: 6px;
      background: #FFFFFF;
      border-radius: 50%;
    }
  </style>
</head>
<body>
  <!-- Full Edge-to-Edge Sacred Buddha Meditation Painting -->
  <img class="bg-image" src="data:image/jpeg;base64,${buddhaB64}" alt="Lord Buddha Meditation Sacred Background" />

  <!-- Soft natural ambient wash on left for crystal text readability without any split screen -->
  <div class="ambient-soft-wash"></div>

  <!-- Content Layer -->
  <div class="content-container">
    <!-- Brand Header -->
    <div class="brand-header">
      <div class="brand-logo-wrapper">
        <img class="brand-logo" src="data:image/png;base64,${logoB64}" alt="All Gujarat Vankar Samaj Logo" />
      </div>
      <div class="brand-text-col">
        <h1 class="brand-title">All Gujarat Vankar Samaj</h1>
        <div class="brand-matrimony">M A T R I M O N Y</div>
        <div class="brand-slogan">Tradition &nbsp;|&nbsp; Trust &nbsp;|&nbsp; Together Forever</div>
      </div>
    </div>

    <!-- Headline -->
    <div class="headline-section">
      <h2 class="headline-primary">
        Find Your
        <span class="headline-accent">Life Partner</span>
      </h2>
      <p class="headline-desc">
        Join our community and discover meaningful relationships within our Vankar Samaj.
      </p>
    </div>

    <!-- Trust Badges -->
    <div class="badges-list">
      <!-- Badge 1: Verified Profiles -->
      <div class="badge-item">
        <div class="badge-icon-box">
          <svg class="badge-icon-svg" viewBox="0 0 24 24">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
          </svg>
        </div>
        <div class="badge-text">
          <span class="badge-title">Verified Profiles</span>
          <span class="badge-sub">Safe &amp; Trusted Community</span>
        </div>
      </div>

      <!-- Badge 2: Wide Community -->
      <div class="badge-item">
        <div class="badge-icon-box">
          <svg class="badge-icon-svg" viewBox="0 0 24 24">
            <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
          </svg>
        </div>
        <div class="badge-text">
          <span class="badge-title">Wide Community</span>
          <span class="badge-sub">Across Gujarat &amp; Beyond</span>
        </div>
      </div>

      <!-- Badge 3: Build Your Future -->
      <div class="badge-item">
        <div class="badge-icon-box">
          <svg class="badge-icon-svg" viewBox="0 0 24 24">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
          </svg>
        </div>
        <div class="badge-text">
          <span class="badge-title">Build Your Future</span>
          <span class="badge-sub">With Someone Who Understands</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Bottom Diagonal Maroon Ribbon -->
  <div class="diagonal-ribbon">
    <svg class="ribbon-svg" viewBox="0 0 440 240" preserveAspectRatio="none">
      <defs>
        <linearGradient id="maroonGrad" x1="0%" y1="100%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#550A19" />
          <stop offset="40%" stop-color="#7B1126" />
          <stop offset="100%" stop-color="#9C1733" />
        </linearGradient>
        <linearGradient id="foldGrad" x1="0%" y1="100%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#400612" />
          <stop offset="100%" stop-color="#600B1D" />
        </linearGradient>
      </defs>
      <!-- Base fold -->
      <polygon points="0,240 0,76 395,240" fill="url(#foldGrad)" />
      <!-- Top layer Ribbon Polygon -->
      <polygon points="0,240 0,88 380,240" fill="url(#maroonGrad)" />
      <!-- Golden Accent Edge line -->
      <line x1="0" y1="88" x2="380" y2="240" stroke="rgba(255, 215, 0, 0.5)" stroke-width="2.2" />
    </svg>
    <div class="ribbon-text-wrapper">
      <div class="ribbon-line-1">Rishte Ka</div>
      <div class="ribbon-line-2">Apna Samaj...</div>
      <div class="ribbon-flourish"></div>
    </div>
  </div>
</body>
</html>
  `;

  await page.setContent(htmlContent, { waitUntil: 'networkidle0' });
  await page.evaluateHandle('document.fonts.ready');

  const outputPath = path.resolve(__dirname, '../application/assets/images/buddha_sacred_login_poster.png');
  const heritagePath = path.resolve(__dirname, '../application/assets/images/heritage_login_poster.png');
  const artifactPath = path.resolve('C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b/buddha_sacred_login_poster_preview.png');

  const screenshotBuffer = await page.screenshot({
    clip: { x: 0, y: 0, width, height },
    type: 'png'
  });

  fs.writeFileSync(outputPath, screenshotBuffer);
  fs.writeFileSync(heritagePath, screenshotBuffer);
  fs.writeFileSync(artifactPath, screenshotBuffer);

  console.log('Saved edge-to-edge Buddha poster to:', outputPath);
  console.log('Synchronized to heritage poster at:', heritagePath);
  console.log('Saved preview to artifact directory:', artifactPath);

  await browser.close();
}

generateBuddhaLoginPoster().catch(err => {
  console.error('Error generating Buddha Login Poster:', err);
  process.exit(1);
});
