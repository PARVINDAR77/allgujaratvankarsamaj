const fs = require('fs');
const path = require('path');

const targetFiles = [
  path.join(__dirname, '../application/build/web/main.dart.js'),
  path.join(__dirname, '../main_dart_live.js')
];

// Gujarati numerals 103 to 113 in unicode escape format
const digits = [
  '\\u0ae7\\u0ae6\\u0ae9.', // 103.
  '\\u0ae7\\u0ae6\\u0aea.', // 104.
  '\\u0ae7\\u0ae6\\u0aeb.', // 105.
  '\\u0ae7\\u0ae6\\u0aec.', // 106.
  '\\u0ae7\\u0ae6\\u0aed.', // 107.
  '\\u0ae7\\u0ae6\\u0aee.', // 108.
  '\\u0ae7\\u0ae6\\u0aef.', // 109.
  '\\u0ae7\\u0ae7\\u0ae6.', // 110.
  '\\u0ae7\\u0ae7\\u0ae7.', // 111.
  '\\u0ae7\\u0ae7\\u0ae8.', // 112.
  '\\u0ae7\\u0ae7\\u0ae9.', // 113.
];

// Raw Gujarati characters as well (in case any raw utf8 occurs)
const rawDigits = [
  '૧૦૩.',
  '૧૦૪.',
  '૧૦૫.',
  '૧૦૬.',
  '૧૦૭.',
  '૧૦૮.',
  '૧૦૯.',
  '૧૧૦.',
  '૧૧૧.',
  '૧૧૨.',
  '૧૧૩.',
];

for (const filePath of targetFiles) {
  if (!fs.existsSync(filePath)) {
    console.log('File does not exist:', filePath);
    continue;
  }

  console.log('Processing:', filePath);
  let content = fs.readFileSync(filePath, 'utf8');
  let totalReplacements = 0;

  for (const d of digits) {
    const p1 = '(' + d + ' ';
    const p2 = '(' + d;
    const p3 = '","' + d + ' ';
    const p4 = '","' + d;

    while (content.includes(p1)) {
      content = content.replace(p1, '(');
      totalReplacements++;
    }
    while (content.includes(p2)) {
      content = content.replace(p2, '(');
      totalReplacements++;
    }
    while (content.includes(p3)) {
      content = content.replace(p3, '","');
      totalReplacements++;
    }
    while (content.includes(p4)) {
      content = content.replace(p4, '","');
      totalReplacements++;
    }
  }

  for (const r of rawDigits) {
    const p1 = '(' + r + ' ';
    const p2 = '(' + r;
    const p3 = '","' + r + ' ';
    const p4 = '","' + r;

    while (content.includes(p1)) {
      content = content.replace(p1, '(');
      totalReplacements++;
    }
    while (content.includes(p2)) {
      content = content.replace(p2, '(');
      totalReplacements++;
    }
    while (content.includes(p3)) {
      content = content.replace(p3, '","');
      totalReplacements++;
    }
    while (content.includes(p4)) {
      content = content.replace(p4, '","');
      totalReplacements++;
    }
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`Successfully replaced ${totalReplacements} pargana serial number occurrences in ${filePath}`);

  // Verification check
  let remaining = 0;
  for (const d of digits) {
    let idx = 0;
    while ((idx = content.indexOf(d, idx)) !== -1) {
      remaining++;
      console.warn(`WARNING: Remaining ${d} at ${idx}`);
      idx += d.length;
    }
  }
  for (const r of rawDigits) {
    let idx = 0;
    while ((idx = content.indexOf(r, idx)) !== -1) {
      remaining++;
      console.warn(`WARNING: Remaining raw ${r} at ${idx}`);
      idx += r.length;
    }
  }
  console.log(`Verification: ${remaining} remaining numbers in ${filePath}`);
}
