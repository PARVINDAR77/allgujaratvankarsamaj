const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const viewports = [
    { name: 'phone', width: 1080, height: 1920 },
    { name: 'ipad', width: 1600, height: 2560 },
    { name: 'laptop', width: 1920, height: 1080 }
];

const flutterRoutes = [
    '/login', '/register', '/home', '/statistics', '/birthdays', 
    '/family-details', '/pargana-overview', '/samaj-services', 
    '/samaj-ratna', '/success-stories', '/search-results', 
    '/search', '/advanced-search', '/match', '/messages', '/profile'
];

const baseUrl = 'http://127.0.0.1:8080/#';
const outputBaseDir = path.join(__dirname, 'flutter_screenshots');

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
    console.log('Starting HTTP server for Flutter Web...');
    const serverProcess = spawn('npx', ['http-server', '-p', '8080'], {
        cwd: path.join(__dirname, 'application', 'build', 'web'),
        shell: true
    });
    
    // Give the server 3 seconds to start
    await new Promise(r => setTimeout(r, 3000));

    console.log('Launching browser...');
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();

    for (const route of flutterRoutes) {
        for (const vp of viewports) {
            console.log(`Capturing ${route} on ${vp.name}...`);
            await page.setViewport({ width: vp.width, height: vp.height });
            
            try {
                // Navigate to the flutter route
                await page.goto(`${baseUrl}${route}`, { waitUntil: 'networkidle0', timeout: 60000 });
                // Flutter canvas needs time to draw
                await new Promise(r => setTimeout(r, 5000));
                
                // Clean the route name for the file
                const safeName = route.replace(/\//g, '_').replace(/^_/, '');
                const screenshotPath = path.join(outputBaseDir, vp.name, `${safeName}.png`);
                await page.screenshot({ path: screenshotPath, fullPage: true });
                console.log(`Saved ${screenshotPath}`);
            } catch (err) {
                console.error(`Error capturing ${route} on ${vp.name}:`, err.message);
            }
        }
    }

    await browser.close();
    serverProcess.kill();
    console.log('Done capturing Flutter App screenshots!');
})();
