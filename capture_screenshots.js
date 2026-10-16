const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const viewports = [
    { name: 'phone', width: 1080, height: 1920 },
    { name: 'ipad', width: 1600, height: 2560 },
    { name: 'laptop', width: 1920, height: 1080 }
];

const adminSections = [
    'dashboard', 'admins', 'advertisements', 'community', 'content', 
    'government-employees', 'health', 'home-screen', 'interests', 
    'locations', 'matches', 'notifications', 'parganas', 'pavan-prernadata', 
    'photos', 'profiles', 'reports', 'samaj-ratna', 'samaj-super-stars', 
    'services', 'settings', 'shortlists', 'users', 'verifications'
];

const baseUrl = 'http://localhost:3005';
const outputBaseDir = path.join(__dirname, 'screenshots_playstore');

if (!fs.existsSync(outputBaseDir)) {
    fs.mkdirSync(outputBaseDir);
}

for (const vp of viewports) {
    const dirPath = path.join(outputBaseDir, vp.name);
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath);
    }
}

(async () => {
    console.log('Launching browser...');
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();

    // Login once
    console.log('Logging into Admin Panel...');
    await page.setViewport({ width: 1920, height: 1080 });
    await page.goto(`${baseUrl}/admin/login`, { waitUntil: 'networkidle2' });
    
    // Fill credentials and login (login page has defaults, but we click anyway)
    // Wait for the form to appear
    await page.waitForSelector('form');
    // Click the login button
    await page.click('button[type="submit"]');
    
    // Wait for client-side navigation to dashboard
    await new Promise(r => setTimeout(r, 5000));
    console.log('Successfully logged in.');

    for (const section of adminSections) {
        const routePath = `/admin/${section}`;
        for (const vp of viewports) {
            console.log(`Capturing ${section} on ${vp.name}...`);
            await page.setViewport({ width: vp.width, height: vp.height });
            
            try {
                await page.goto(`${baseUrl}${routePath}`, { waitUntil: 'networkidle2', timeout: 60000 });
                // wait for 3 seconds for content to load
                await new Promise(r => setTimeout(r, 3000));
                
                const screenshotPath = path.join(outputBaseDir, vp.name, `${section}.png`);
                await page.screenshot({ path: screenshotPath, fullPage: true });
                console.log(`Saved ${screenshotPath}`);
            } catch (err) {
                console.error(`Error capturing ${section} on ${vp.name}:`, err.message);
            }
        }
    }

    await browser.close();
    console.log('Done capturing screenshots for all admin sections!');
})();
