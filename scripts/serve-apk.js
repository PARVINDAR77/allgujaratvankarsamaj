const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PORT = 8080;
const POSSIBLE_PATHS = [
  path.resolve(__dirname, '../application/android/app/build/outputs/apk/release/app-release.apk'),
  path.resolve(__dirname, '../application/build/app/outputs/flutter-apk/app-release.apk'),
  path.resolve(__dirname, '../vankar_samaj_matrimony.apk'),
];

function getApkPath() {
  for (const p of POSSIBLE_PATHS) {
    if (fs.existsSync(p)) return p;
  }
  return POSSIBLE_PATHS[0];
}

const APK_PATH = getApkPath();

function getLanIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    if (name.toLowerCase().includes('vethernet') || name.toLowerCase().includes('wsl')) continue;
    for (const net of interfaces[name]) {
      if (net.family === 'IPv4' && !net.internal && net.address.startsWith('192.168.')) {
        return net.address;
      }
    }
  }
  return '192.168.1.18';
}

const LAN_IP = getLanIp();

const server = http.createServer((req, res) => {
  const url = req.url.split('?')[0];

  if (url === '/vankar_samaj_matrimony.apk' || url === '/download') {
    if (!fs.existsSync(APK_PATH)) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('APK build not found yet. Please wait for the build to complete.');
      return;
    }

    const stat = fs.statSync(APK_PATH);
    res.writeHead(200, {
      'Content-Type': 'application/vnd.android.package-archive',
      'Content-Disposition': 'attachment; filename="vankar_samaj_matrimony.apk"',
      'Content-Length': stat.size,
      'Cache-Control': 'no-cache',
    });

    const readStream = fs.createReadStream(APK_PATH);
    readStream.pipe(res);
    return;
  }

  if (url === '/' || url === '/index.html') {
    let apkSizeMb = 'Available';
    let fileExists = fs.existsSync(APK_PATH);
    if (fileExists) {
      const stat = fs.statSync(APK_PATH);
      apkSizeMb = (stat.size / (1024 * 1024)).toFixed(1) + ' MB';
    }

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Vankar Samaj Matrimony - Mobile App Download</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #800020;
      --primary-dark: #580015;
      --primary-light: #a31535;
      --accent: #d4af37;
      --accent-hover: #b89726;
      --bg: #0f172a;
      --card-bg: rgba(30, 41, 59, 0.85);
      --card-border: rgba(255, 255, 255, 0.1);
      --text: #f8fafc;
      --text-muted: #94a3b8;
      --success: #10b981;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background: radial-gradient(circle at top center, #2e1065 0%, #0f172a 70%);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
      text-align: center;
    }

    .container {
      max-width: 480px;
      width: 100%;
      background: var(--card-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid var(--card-border);
      border-radius: 28px;
      padding: 2.25rem 1.75rem;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6), 0 0 40px rgba(128, 0, 32, 0.2);
    }

    .logo-badge {
      width: 88px;
      height: 88px;
      margin: 0 auto 1.25rem;
      background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
      border-radius: 22px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2.5rem;
      box-shadow: 0 10px 25px rgba(128, 0, 32, 0.4);
    }

    h1 {
      font-family: 'Outfit', sans-serif;
      font-size: 1.85rem;
      font-weight: 800;
      letter-spacing: -0.02em;
      margin-bottom: 0.35rem;
      background: linear-gradient(135deg, #ffffff 40%, #e2e8f0 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .subtitle {
      color: var(--accent);
      font-size: 0.95rem;
      font-weight: 600;
      margin-bottom: 1.25rem;
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }

    .meta-badges {
      display: flex;
      justify-content: center;
      gap: 0.75rem;
      margin-bottom: 1.75rem;
      flex-wrap: wrap;
    }

    .badge {
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid rgba(255, 255, 255, 0.1);
      padding: 0.35rem 0.85rem;
      border-radius: 9999px;
      font-size: 0.8rem;
      color: var(--text-muted);
      font-weight: 500;
    }

    .badge strong {
      color: #fff;
    }

    .btn-download {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.75rem;
      width: 100%;
      background: linear-gradient(135deg, var(--primary-light) 0%, var(--primary) 100%);
      color: #ffffff;
      text-decoration: none;
      font-size: 1.15rem;
      font-weight: 700;
      padding: 1.1rem;
      border-radius: 16px;
      border: 1px solid rgba(255, 255, 255, 0.15);
      box-shadow: 0 10px 25px rgba(128, 0, 32, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.1);
      transition: all 0.2s ease;
      cursor: pointer;
    }

    .btn-download:hover, .btn-download:active {
      transform: translateY(-2px);
      box-shadow: 0 15px 30px rgba(128, 0, 32, 0.5);
      background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    }

    .instructions {
      margin-top: 1.75rem;
      text-align: left;
      background: rgba(15, 23, 42, 0.6);
      border-radius: 16px;
      padding: 1.25rem;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }

    .instructions-title {
      font-size: 0.85rem;
      font-weight: 700;
      color: var(--text);
      margin-bottom: 0.75rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .step-list {
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      font-size: 0.82rem;
      color: var(--text-muted);
    }

    .step-list li {
      display: flex;
      align-items: flex-start;
      gap: 0.6rem;
      line-height: 1.4;
    }

    .step-num {
      background: rgba(212, 175, 55, 0.2);
      color: var(--accent);
      font-weight: 700;
      font-size: 0.75rem;
      width: 18px;
      height: 18px;
      border-radius: 50%;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      margin-top: 2px;
    }

    .status-bar {
      margin-top: 1.5rem;
      font-size: 0.78rem;
      color: var(--text-muted);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }

    .status-dot {
      width: 8px;
      height: 8px;
      background: var(--success);
      border-radius: 50%;
      box-shadow: 0 0 10px var(--success);
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo-badge">💍</div>
    <h1>Vankar Samaj Matrimony</h1>
    <div class="subtitle">Official Android Release</div>

    <div class="meta-badges">
      <div class="badge">Version: <strong>1.0.0</strong></div>
      <div class="badge">Size: <strong>${apkSizeMb}</strong></div>
      <div class="badge">Platform: <strong>Android 5.0+</strong></div>
    </div>

    <a href="/vankar_samaj_matrimony.apk" class="btn-download" download>
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
      </svg>
      Download APK
    </a>

    <div class="instructions">
      <div class="instructions-title">
        <span>📲</span> How to Install on your Phone
      </div>
      <ol class="step-list">
        <li>
          <span class="step-num">1</span>
          <span>Tap the <b>Download APK</b> button above.</span>
        </li>
        <li>
          <span class="step-num">2</span>
          <span>If Chrome prompts <i>"File might be harmful"</i>, tap <b>Download anyway</b>.</span>
        </li>
        <li>
          <span class="step-num">3</span>
          <span>When finished, tap <b>Open</b> or find the APK in your <b>Downloads</b> folder.</span>
        </li>
        <li>
          <span class="step-num">4</span>
          <span>If prompted to <i>"Install unknown apps"</i>, tap <b>Settings</b> and enable <b>Allow from this source</b>.</span>
        </li>
        <li>
          <span class="step-num">5</span>
          <span>Tap <b>Install</b>, then launch <b>Vankar Samaj Matrimony</b>!</span>
        </li>
      </ol>
    </div>

    <div class="status-bar">
      <span class="status-dot"></span>
      <span>Connected to LAN Backend (192.168.1.18:3000)</span>
    </div>
  </div>
</body>
</html>`;

    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not Found');
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n======================================================`);
  console.log(`🚀 APK Download Server is RUNNING!`);
  console.log(`📱 Open this link on your Mobile Phone Browser:`);
  console.log(`👉 http://${LAN_IP}:${PORT}`);
  console.log(`👉 Direct APK: http://${LAN_IP}:${PORT}/vankar_samaj_matrimony.apk`);
  console.log(`💻 Local computer preview: http://localhost:${PORT}`);
  console.log(`======================================================\n`);
});
