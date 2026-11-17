const fs = require('fs');
const path = require('path');

const mainDartJsPath = path.join(__dirname, '../application/build/web/main.dart.js');
const mainDartLivePath = path.join(__dirname, '../main_dart_live.js');

console.log('=== Removing Add Business Banner from Web Bundles ===');

// 1. Patch application/build/web/main.dart.js
if (fs.existsSync(mainDartJsPath)) {
  console.log('Patching', mainDartJsPath);
  let content = fs.readFileSync(mainDartJsPath, 'utf8');

  // a. Remove from b8e children list
  const targetB8e = 'o.aro(r),B.a0,o.apW(r,a),B.a0,o.ar8(r,this.b,this.c)';
  const cleanB8e = 'o.aro(r),B.a0,o.ar8(r,this.b,this.c)';
  if (content.includes(targetB8e)) {
    content = content.replace(targetB8e, cleanB8e);
    console.log('Removed o.apW from b8e children list in main.dart.js');
  } else {
    console.log('targetB8e not found, checking if already removed');
  }

  // b. Neutralize apW method implementation to return B.aF (const SizedBox.shrink())
  const pApW = content.indexOf('apW(a,b){');
  if (pApW !== -1) {
    const pNext = content.indexOf('ar8(a,b,c){', pApW);
    if (pNext !== -1 && pNext - pApW < 3000) {
      content = content.substring(0, pApW) + 'apW(a,b){return B.aF},\n' + content.substring(pNext);
      console.log('Neutralized apW method in main.dart.js to return B.aF');
    }
  }

  fs.writeFileSync(mainDartJsPath, content, 'utf8');
  console.log('Saved main.dart.js');
}

// 2. Patch main_dart_live.js
if (fs.existsSync(mainDartLivePath)) {
  console.log('Patching', mainDartLivePath);
  let content = fs.readFileSync(mainDartLivePath, 'utf8');

  // a. Remove from children list
  const targetLiveList = 'o.ark(r),B.a_,o.apR(r,a),B.a_,o.ar3(r,this.b,this.c)';
  const cleanLiveList = 'o.ark(r),B.a_,o.ar3(r,this.b,this.c)';
  if (content.includes(targetLiveList)) {
    content = content.replace(targetLiveList, cleanLiveList);
    console.log('Removed o.apR from children list in main_dart_live.js');
  }

  // b. Neutralize apR method implementation to return B.aI (const SizedBox.shrink())
  const pApR = content.indexOf('apR(a,b){');
  if (pApR !== -1) {
    const pNext = content.indexOf('ar3(a,b,c){', pApR);
    if (pNext !== -1 && pNext - pApR < 3000) {
      content = content.substring(0, pApR) + 'apR(a,b){return B.aI},\n' + content.substring(pNext);
      console.log('Neutralized apR method in main_dart_live.js to return B.aI');
    }
  }

  fs.writeFileSync(mainDartLivePath, content, 'utf8');
  console.log('Saved main_dart_live.js');
}

console.log('=== Finished Removing Add Business Banner ===');
