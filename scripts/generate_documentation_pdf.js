const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function generatePdf() {
  const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>All Gujarat Vankar Samaj - Platform Documentation</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Noto+Sans+Gujarati:wght@400;600;700&display=swap');

    @page {
      size: A4;
      margin: 18mm 16mm 18mm 16mm;
    }

    * {
      box-sizing: border-box;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
    }

    body {
      font-family: 'Inter', 'Noto Sans Gujarati', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: #1e293b;
      line-height: 1.55;
      font-size: 11pt;
      margin: 0;
      padding: 0;
      background: #ffffff;
    }

    /* Cover / Header Banner */
    .header-banner {
      background: linear-gradient(135deg, #041126 0%, #1e3a8a 100%);
      color: #ffffff;
      padding: 28px 24px;
      border-radius: 12px;
      margin-bottom: 24px;
      border-bottom: 4px solid #d4af37;
    }

    .header-banner h1 {
      font-size: 22pt;
      font-weight: 800;
      margin: 0 0 6px 0;
      color: #ffffff;
      letter-spacing: -0.5px;
    }

    .header-banner .tagline {
      font-size: 12pt;
      color: #d4af37;
      font-weight: 600;
      margin-bottom: 12px;
    }

    .header-banner .meta {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      font-size: 9pt;
      color: #cbd5e1;
    }

    .meta-item {
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }

    .meta-item strong {
      color: #ffffff;
    }

    /* Headings */
    h2 {
      font-size: 14pt;
      font-weight: 700;
      color: #0f172a;
      border-bottom: 2px solid #e2e8f0;
      padding-bottom: 6px;
      margin-top: 24px;
      margin-bottom: 12px;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    h2 .num {
      background: #1e3a8a;
      color: #ffffff;
      font-size: 10pt;
      padding: 2px 8px;
      border-radius: 6px;
    }

    h3 {
      font-size: 11.5pt;
      font-weight: 600;
      color: #1e3a8a;
      margin-top: 14px;
      margin-bottom: 6px;
    }

    p {
      margin: 0 0 10px 0;
      color: #334155;
    }

    ul, ol {
      margin: 0 0 12px 0;
      padding-left: 20px;
      color: #334155;
    }

    li {
      margin-bottom: 4px;
    }

    /* Callout Boxes */
    .callout {
      padding: 12px 16px;
      border-radius: 8px;
      margin: 12px 0;
      font-size: 10pt;
    }

    .callout-info {
      background: #eff6ff;
      border-left: 4px solid #2563eb;
      color: #1e40af;
    }

    .callout-success {
      background: #ecfdf5;
      border-left: 4px solid #10b981;
      color: #065f46;
    }

    .callout-warning {
      background: #fffbeb;
      border-left: 4px solid #f59e0b;
      color: #92400e;
    }

    /* Badges */
    .badge {
      display: inline-block;
      padding: 2px 7px;
      font-size: 8.5pt;
      font-weight: 600;
      border-radius: 4px;
      white-space: nowrap;
    }

    .badge-primary { background: #dbeafe; color: #1e40af; }
    .badge-success { background: #d1fae5; color: #065f46; }
    .badge-warning { background: #fef3c7; color: #92400e; }
    .badge-gold { background: #fef08a; color: #854d0e; }

    /* Tables */
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
      font-size: 9.5pt;
    }

    th, td {
      border: 1px solid #e2e8f0;
      padding: 7px 10px;
      text-align: left;
      vertical-align: top;
    }

    th {
      background-color: #f1f5f9;
      font-weight: 700;
      color: #0f172a;
    }

    tr:nth-child(even) {
      background-color: #f8fafc;
    }

    /* Architecture Box */
    .arch-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 12px;
      margin: 12px 0;
    }

    .arch-card {
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      padding: 12px;
      background: #f8fafc;
    }

    .arch-card h4 {
      margin: 0 0 6px 0;
      color: #1e3a8a;
      font-size: 10pt;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .arch-card p {
      font-size: 9pt;
      margin: 0;
      color: #475569;
    }

    /* Code block */
    code, pre {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 9pt;
    }

    code {
      background: #f1f5f9;
      padding: 1px 4px;
      border-radius: 4px;
      color: #0f172a;
    }

    pre {
      background: #0f172a;
      color: #f8fafc;
      padding: 12px;
      border-radius: 8px;
      overflow-x: auto;
      margin: 10px 0;
      line-height: 1.4;
    }

    .page-break {
      page-break-after: always;
    }
  </style>
</head>
<body>

  <!-- Title Banner -->
  <div class="header-banner">
    <h1>All Gujarat Vankar Samaj</h1>
    <div class="tagline">સંપૂર્ણ ડિજિટલ પરિચય અને મેટ્રિમોનિયલ પ્લેટફોર્મ (Official Platform Documentation)</div>
    <div class="meta">
      <div class="meta-item"><strong>Live URL:</strong> https://allgujaratvankarsamaj.com</div>
      <div class="meta-item"><strong>Status:</strong> Production Ready</div>
      <div class="meta-item"><strong>Version:</strong> 1.0.10+11</div>
      <div class="meta-item"><strong>Updated:</strong> October 2026</div>
    </div>
  </div>

  <!-- Section 1: Executive Summary -->
  <h2><span class="num">1</span> Executive Summary & Platform Mission</h2>
  <p>
    <strong>All Gujarat Vankar Samaj</strong> is a premier, community-driven digital matrimonial, socio-cultural, and career networking platform engineered specifically for the <strong>Vankar Samaj</strong> community across Gujarat, India, and the international diaspora.
  </p>
  <p>
    The portal bridges rich cultural traditions with cutting-edge technology:
  </p>
  <ul>
    <li><strong>100% Genuine Matrimonial Matchmaking:</strong> Candidate profiles with mandatory government ID proof verification, verified contact flags, and dual-side image capture.</li>
    <li><strong>AI-Powered Identity Verification:</strong> Live multimodal vision checks using Google Gemini AI, cross-verifying candidate Name and Date of Birth against uploaded ID documents to prevent identity fraud.</li>
    <li><strong>Cultural Lineage & Directory:</strong> Interactive repository of all Vankar Parganas, Talukas, and Native Villages (મૂળ ગામ અને મોસાળ ગામ).</li>
    <li><strong>Community Pride & Honors:</strong> Recognition hubs honoring Samaj Super Stars, Samaj Ratna awardees, Pavan Prernadata (mentors), and verified Government Employees (IAS, Police, Teachers, Bank officers).</li>
    <li><strong>Social Upliftment & Services:</strong> Samaj Sevaks emergency network, education scholarships, competitive exam coaching, and verified business advertisements.</li>
  </ul>

  <!-- Section 2: Architecture & Tech Stack -->
  <h2><span class="num">2</span> High-Level System Architecture & Tech Stack</h2>
  <div class="arch-grid">
    <div class="arch-card">
      <h4>📱 Frontend (Multiplatform Web & Mobile)</h4>
      <p><strong>Flutter 3.47 / Dart 3.13</strong><br>
      Single responsive codebase delivering Flutter Web (WASM/CanvasKit/HTML) and native Android/iOS builds. State managed via <strong>Riverpod 2.6</strong> with <strong>GoRouter 14.8</strong> deep linking.</p>
    </div>
    <div class="arch-card">
      <h4>⚡ Backend API (Enterprise NestJS)</h4>
      <p><strong>NestJS 10.4 / Node.js 20+</strong><br>
      High-concurrency modular backend implementing RESTful APIs, Swagger documentation, JWT authentication, and automated error handling.</p>
    </div>
    <div class="arch-card">
      <h4>🗄️ Database & ORM</h4>
      <p><strong>Prisma ORM 5.22 + MySQL / PostgreSQL</strong><br>
      Fully normalized relational database schema with type-safe queries, automatic migrations, and indexed foreign key relationships.</p>
    </div>
    <div class="arch-card">
      <h4>🧠 Artificial Intelligence & Vision Engine</h4>
      <p><strong>Google Gemini 1.5 Flash Vision AI</strong><br>
      Sub-second multimodal document analysis validating government IDs, extracting bilingual Gujarati/English text, and validating candidate name/DOB.</p>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Component</th>
        <th>Technology</th>
        <th>Key Role</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Web Gateway</strong></td>
        <td>Apache + PHP 8.3 Reverse Proxy</td>
        <td>High-speed Unix Domain Socket (<code>backend.sock</code>) proxy with automated watchdog auto-restart (<code>api_proxy.php</code>).</td>
      </tr>
      <tr>
        <td><strong>Authentication</strong></td>
        <td>Passport-JWT & Bcrypt</td>
        <td>Dual identifier login (Phone or Email), salted password hashing, 7-day token expiration, and RBAC permissions.</td>
      </tr>
      <tr>
        <td><strong>Storage Engine</strong></td>
        <td>Dual-Tier Storage Service</td>
        <td>Public media in <code>/uploads</code> (avatars, galleries) and private secured storage in <code>/private_uploads</code> (Aadhaar, Govt IDs) protected by RBAC streaming.</td>
      </tr>
      <tr>
        <td><strong>OTP Service</strong></td>
        <td>Fast2SMS & SMTP Gateway</td>
        <td>4-digit / 6-digit OTP delivery with automated 40-second cooldown timer and resend lockout guards.</td>
      </tr>
    </tbody>
  </table>

  <div class="page-break"></div>

  <!-- Section 3: Feature Modules -->
  <h2><span class="num">3</span> Complete Feature Guide</h2>

  <h3>3.1 Authentication & Registration</h3>
  <ul>
    <li><strong>Dual-Identifier Login (<code>/login</code>):</strong> Login via 10-digit mobile number OR email address. Session auto-refreshed via <code>/auth/me</code> to prevent profile field loss.</li>
    <li><strong>OTP Verification with 40-Second Cooldown (<code>/register</code>):</strong>
      <ul>
        <li>Real-time countdown timer: <code>Resend in 40s</code>.</li>
        <li>Bilingual guidance alert displayed on expiration: <em>"OTP કોડ નથી મળ્યો? ફરી કોડ મોકલવા માટે ઉપર 'ફરી કોડ મોકલો' બટન દબાવો."</em></li>
        <li>Phone & Email verification synchronization with user account.</li>
      </ul>
    </li>
    <li><strong>Password Recovery & Update:</strong> In-app password change modal and self-service credential updates.</li>
  </ul>

  <h3>3.2 Matrimonial Profiles (Create & Edit)</h3>
  <ul>
    <li><strong>Personal Profile:</strong> First Name, Last Name, Gender, Date of Birth (calendar picker), Marital Status (Never Married, Divorced, Widowed), Blood Group, Mother Tongue.</li>
    <li><strong>Community Lineage:</strong> Sub-caste, Pargana selection, Native Village (મૂળ ગામ), Mother's Village (મામાનું ગામ), Taluka, District, State, Country.</li>
    <li><strong>Education & Career:</strong> Qualifications (Doctor, Engineer, CA/CS, MBA, Graduate, etc.), Employment Sector (Govt Central, Govt State, Corporate, Business, Abroad), Designation, Annual Income.</li>
    <li><strong>Family Details:</strong> Father's Name & Occupation, Mother's Name & Occupation, Siblings, Guardian contact.</li>
    <li><strong>Photo Gallery:</strong> High-resolution primary profile picture + 2 to 5 lifestyle gallery photos with client-side 5 MB enforcement.</li>
    <li><strong>3-Tier Privacy Settings:</strong> Independent visibility settings for Mobile Number, Email, and Address (<code>બધા માટે</code> / <code>પરિવારજનો</code> / <code>માત્ર મને</code>).</li>
  </ul>

  <h3>3.3 AI-Powered Government ID Document Verification</h3>
  <div class="callout callout-success">
    <strong>Strict AI Verification Pipeline:</strong> When a user attaches their Aadhaar Card, PAN Card, Voter ID, or Driving License, the system triggers live Google Gemini Vision AI to read the document.
  </div>
  <ul>
    <li><strong>Name Cross-Check:</strong> Extracts name in English and Gujarati; intelligently accounts for Indian honorifics (<em>bhai</em>, <em>kumar</em>, <em>ben</em>, <em>devi</em>) and father's middle name.</li>
    <li><strong>Date of Birth Cross-Check:</strong> Validates full <code>DD/MM/YYYY</code> dates or Aadhaar birth years (<code>Year of Birth: YYYY</code>).</li>
    <li><strong>Strict Zero-False-Positive Visual State:</strong>
      <ul>
        <li>The card border and status banner <strong>never</strong> turn green based solely on file selection.</li>
        <li>Green badge <code>✓ AI Verified</code> and status <code>✓ ઓળખપત્ર AI દ્વારા ચકાસાયેલ છે</code> strictly require real AI verification approval.</li>
        <li>Mismatched or fake documents (such as uploading someone else's ID) are <strong>rejected immediately and blocked from attaching</strong>.</li>
      </ul>
    </li>
  </ul>

  <div class="page-break"></div>

  <!-- Section 4: Community & Directory Modules -->
  <h2><span class="num">4</span> Community, Lineage & Directory Portals</h2>
  <table>
    <thead>
      <tr>
        <th>Portal Route</th>
        <th>Module Name</th>
        <th>Description & Purpose</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>/pargana-overview</code></td>
        <td><strong>Pargana & Village Directory</strong></td>
        <td>Interactive directory listing all Parganas across Gujarat, registered talukas, villages, and community leader contact info.</td>
      </tr>
      <tr>
        <td><code>/government-employees</code></td>
        <td><strong>Government Employees Cell</strong></td>
        <td>Roster of community civil servants, police officers, railway officials, bank managers, and educators with verified badges.</td>
      </tr>
      <tr>
        <td><code>/samaj-super-stars</code></td>
        <td><strong>Samaj Super Stars</strong></td>
        <td>Hall of fame celebrating high achievers, entrepreneurs, national awardees, and sports personalities.</td>
      </tr>
      <tr>
        <td><code>/samaj-ratna</code></td>
        <td><strong>Samaj Ratna Awards</strong></td>
        <td>Lifetime honor roll recognizing distinguished elders and community benefactors.</td>
      </tr>
      <tr>
        <td><code>/pavan-prernadata</code></td>
        <td><strong>Pavan Prernadata</strong></td>
        <td>Historical leaders, spiritual guides, and inspiring mentors of the Vankar Samaj.</td>
      </tr>
      <tr>
        <td><code>/samaj-services</code></td>
        <td><strong>Samaj Services & Sevaks</strong></td>
        <td>Directory of volunteer social workers, emergency blood donors, medical aid coordinators, and funeral assistance.</td>
      </tr>
      <tr>
        <td><code>/education</code></td>
        <td><strong>Education & Career Hub</strong></td>
        <td>GPSC/UPSC competitive exam coaching materials, student scholarship opportunities, and hostel directories.</td>
      </tr>
      <tr>
        <td><code>/family-details</code></td>
        <td><strong>Family & Lineage Archive</strong></td>
        <td>Digital tree capturing family lineage, native roots, and genealogical ties.</td>
      </tr>
      <tr>
        <td><code>/success-stories</code></td>
        <td><strong>Success Stories</strong></td>
        <td>Couples united through the platform with wedding pictures and family testimonials.</td>
      </tr>
      <tr>
        <td><code>/statistics</code></td>
        <td><strong>Community Analytics</strong></td>
        <td>Demographic charts covering education levels, district distributions, and employment ratios.</td>
      </tr>
    </tbody>
  </table>

  <!-- Section 5: Matchmaking & Communication -->
  <h2><span class="num">5</span> Discovery, Matchmaking & Communication</h2>
  <ul>
    <li><strong>Quick & Advanced Search (<code>/search</code>, <code>/advanced-search</code>):</strong> Multi-criteria search by age range, height, sub-caste, pargana, village, education degree, sector, and income.</li>
    <li><strong>Candidate Profile Details (<code>/candidate-profile-details</code>):</strong> Rich biodata view with picture zoom, horoscope details, family info, and one-tap <em>Express Interest</em> (રસ દાખવો).</li>
    <li><strong>Match Recommendations (<code>/match</code>):</strong> Daily mutual compatibility suggestions based on age, education, and pargana preferences.</li>
    <li><strong>Real-Time 1-to-1 Chat (<code>/chat/:conversationId</code>):</strong> Private messaging between mutual matches with image and document exchange.</li>
  </ul>

  <!-- Section 6: Administration -->
  <h2><span class="num">6</span> Administration & Moderation Panel</h2>
  <ul>
    <li><strong>Executive KPI Dashboard:</strong> Real-time counts for Total Profiles, Pending ID Verifications, Active Members, and Daily Traffic.</li>
    <li><strong>Verification Queue (<code>/admin/verifications</code>):</strong> Side-by-side inspection of Front and Back ID photos, AI confidence score, and one-click Approve / Reject with custom message.</li>
    <li><strong>OTP Telemetry:</strong> Live metrics tracking SMS delivery success rate, carrier latencies, and failure trends.</li>
    <li><strong>User Moderation:</strong> Suspend fraudulent users, review community reports, and feature verified profiles.</li>
  </ul>

  <div class="callout callout-info" style="margin-top: 24px;">
    <strong>Document Certification:</strong> This technical documentation accurately reflects the live production architecture, Flutter 3.47 frontend codebase, and NestJS backend implementation of <strong>All Gujarat Vankar Samaj</strong> as of October 2026.
  </div>

</body>
</html>`;

  console.log('Launching Puppeteer headless browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setContent(htmlContent, { waitUntil: 'networkidle0' });

  const outputWorkspacePath = path.resolve(__dirname, '..', 'All_Gujarat_Vankar_Samaj_Platform_Documentation.pdf');
  const outputArtifactPath = 'C:\\Users\\SEO STZK\\.gemini\\antigravity\\brain\\114e8486-5596-4829-9ee3-5fe17f3c8c80\\All_Gujarat_Vankar_Samaj_Platform_Documentation.pdf';

  console.log('Rendering PDF to workspace...');
  await page.pdf({
    path: outputWorkspacePath,
    format: 'A4',
    printBackground: true,
    margin: {
      top: '14mm',
      bottom: '16mm',
      left: '14mm',
      right: '14mm'
    },
    displayHeaderFooter: true,
    headerTemplate: '<div></div>',
    footerTemplate: `
      <div style="width: 100%; font-size: 8pt; font-family: sans-serif; color: #94a3b8; display: flex; justify-content: space-between; padding: 0 14mm;">
        <span>All Gujarat Vankar Samaj • Official Technical Documentation</span>
        <span>Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
      </div>
    `
  });

  // Copy to artifacts directory
  fs.copyFileSync(outputWorkspacePath, outputArtifactPath);

  await browser.close();

  const stats = fs.statSync(outputWorkspacePath);
  console.log(`PDF successfully created! Size: ${(stats.size / 1024).toFixed(1)} KB`);
  console.log('Saved at:', outputWorkspacePath);
  console.log('Saved at:', outputArtifactPath);
}

generatePdf().catch(err => {
  console.error('Error generating PDF:', err);
  process.exit(1);
});

