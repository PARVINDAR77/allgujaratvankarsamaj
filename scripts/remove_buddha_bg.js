const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function processBuddha() {
  console.log('Starting high-precision background removal for Buddha statue...');
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();

  const srcPath = 'C:/Users/SEO STZK/.gemini/antigravity-ide/brain/9fbfa128-2d42-4417-b66d-47228f05386b/.user_uploaded/media_1792667084235.jpg';
  const outPath = path.resolve(__dirname, '../application/assets/images/buddha_golden_statue_transparent.png');
  const base64 = fs.readFileSync(srcPath).toString('base64');

  const pngBase64 = await page.evaluate(async (b64) => {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        const w = img.width;
        const h = img.height;
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);

        const imgData = ctx.getImageData(0, 0, w, h);
        const data = imgData.data;

        // Helper to check if a pixel is background white / near-white
        // Threshold: R > 235, G > 235, B > 235, and low saturation
        const isWhite = (i) => {
          const r = data[i];
          const g = data[i + 1];
          const b = data[i + 2];
          // Pure or off-white background check
          if (r >= 238 && g >= 238 && b >= 238) return true;
          // Soft halos/glows near edges that are predominantly white
          const min = Math.min(r, g, b);
          const max = Math.max(r, g, b);
          if (min >= 225 && (max - min) <= 18) return true;
          return false;
        };

        // BFS flood fill from all perimeter pixels
        const visited = new Uint8Array(w * h);
        const queue = new Int32Array(w * h);
        let qHead = 0;
        let qTail = 0;

        // Push perimeter pixels
        for (let x = 0; x < w; x++) {
          // Top row
          const topIdx = x;
          if (isWhite(topIdx * 4)) {
            visited[topIdx] = 1;
            queue[qTail++] = topIdx;
          }
          // Bottom row
          const botIdx = (h - 1) * w + x;
          if (isWhite(botIdx * 4)) {
            visited[botIdx] = 1;
            queue[qTail++] = botIdx;
          }
        }

        for (let y = 0; y < h; y++) {
          // Left col
          const leftIdx = y * w;
          if (!visited[leftIdx] && isWhite(leftIdx * 4)) {
            visited[leftIdx] = 1;
            queue[qTail++] = leftIdx;
          }
          // Right col
          const rightIdx = y * w + (w - 1);
          if (!visited[rightIdx] && isWhite(rightIdx * 4)) {
            visited[rightIdx] = 1;
            queue[qTail++] = rightIdx;
          }
        }

        // BFS exploration
        const neighbors = [-1, 1, -w, w];
        while (qHead < qTail) {
          const curr = queue[qHead++];
          const cx = curr % w;
          const cy = Math.floor(curr / w);

          for (let k = 0; k < 4; k++) {
            const next = curr + neighbors[k];
            if (next < 0 || next >= w * h) continue;

            const nx = next % w;
            const ny = Math.floor(next / w);
            // Ensure no horizontal wrap
            if (Math.abs(cx - nx) > 1 || Math.abs(cy - ny) > 1) continue;

            if (!visited[next] && isWhite(next * 4)) {
              visited[next] = 1;
              queue[qTail++] = next;
            }
          }
        }

        // Apply transparency to visited background pixels
        for (let idx = 0; idx < w * h; idx++) {
          if (visited[idx]) {
            data[idx * 4 + 3] = 0; // Transparent
          }
        }

        // Smooth feathering pass on the edge pixels
        // Any non-visited pixel with visited neighbors gets partial alpha based on brightness
        for (let y = 1; y < h - 1; y++) {
          for (let x = 1; x < w - 1; x++) {
            const idx = y * w + x;
            if (visited[idx]) continue;

            // Check if it borders transparent pixels
            let bgNeighborCount = 0;
            if (visited[idx - 1]) bgNeighborCount++;
            if (visited[idx + 1]) bgNeighborCount++;
            if (visited[idx - w]) bgNeighborCount++;
            if (visited[idx + w]) bgNeighborCount++;

            if (bgNeighborCount > 0) {
              const pi = idx * 4;
              const r = data[pi];
              const g = data[pi + 1];
              const b = data[pi + 2];
              const brightness = (r + g + b) / 3;

              // If very close to white on the boundary, blend alpha smoothly
              if (brightness > 210) {
                const alphaFactor = Math.max(0, (255 - brightness) / 45);
                data[pi + 3] = Math.round(255 * alphaFactor);
              }
            }
          }
        }

        ctx.putImageData(imgData, 0, 0);
        resolve(canvas.toDataURL('image/png').split(',')[1]);
      };
      img.src = 'data:image/jpeg;base64,' + b64;
    });
  }, base64);

  fs.writeFileSync(outPath, Buffer.from(pngBase64, 'base64'));
  console.log('Saved transparent Buddha PNG to:', outPath);
  await browser.close();
}

processBuddha().catch(err => {
  console.error('Processing failed:', err);
  process.exit(1);
});
