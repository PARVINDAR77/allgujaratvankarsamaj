const fs = require('fs');
const path = require('path');

const VERSION_TAG = '20261104_matrimony_home_fixed_v67';

function patchMainDartJs() {
  const filePath = path.join(__dirname, '../application/build/web/main.dart.js');
  console.log('Patching', filePath);
  let content = fs.readFileSync(filePath, 'utf8');

  // 1. Ensure vW returns isApproved: true (!0 instead of !1)
  const targetVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!1,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  const replaceVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!0,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  if (!content.includes(targetVw) && !content.includes(replaceVw)) {
    throw new Error('Target vW not found in main.dart.js');
  }
  content = content.replace(targetVw, replaceVw);

  // 2. Ensure /advanced-search, /home, and /search routes are defined and in top-level routes
  if (content.includes('b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s)')) {
    if (!content.includes('b_home=')) {
      content = content.replace(
        'b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s)',
        'b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.bf_(),"home","/home",s),b_search=A.dv(new A.bf0(),"search","/search",s)'
      );
      console.log('Added b_home and b_search definitions in main.dart.js');
    }
  } else {
    const targetRouteDef = 'b1=A.dv(new A.beT(),"search-results","/search-results",s),b2=A.dv(new A.beU(),"candidate-profile-details","/candidate-profile-details",s)';
    const replaceRouteDef = 'b1=A.dv(new A.beT(),"search-results","/search-results",s),b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.bf_(),"home","/home",s),b_search=A.dv(new A.bf0(),"search","/search",s),b2=A.dv(new A.beU(),"candidate-profile-details","/candidate-profile-details",s)';
    if (content.includes(targetRouteDef)) {
      content = content.replace(targetRouteDef, replaceRouteDef);
      console.log('Added b_adv, b_home, and b_search definitions in main.dart.js');
    }
  }

  // Update top-level route array q
  if (content.includes('b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Added b_home and b_search to top-level routes array in main.dart.js');
  } else if (content.includes('b0,b1,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Added b_adv, b_home, and b_search to top-level routes array in main.dart.js');
  }

  // 3. Remove IntrinsicHeight from search TextField
  const targetJ8 = 'h=A.h(a6,new A.J8(A.r(A.a([B.bi,B.adC,B.a5,';
  if (content.includes(targetJ8)) {
    const idx = content.indexOf(targetJ8);
    const endPattern = ',B.aM,B.c,B.e,0),a6)';
    const endIdx = content.indexOf(endPattern, idx);
    if (endIdx !== -1 && endIdx - idx < 2000) {
      const before = content.substring(0, idx);
      const middle = content.substring(idx + 'h=A.h(a6,new A.J8('.length, endIdx);
      const after = content.substring(endIdx + endPattern.length);
      content = before + 'h=A.h(a6,' + middle + ',B.aM,B.c,B.e,0)' + after;
      console.log('Removed IntrinsicHeight (new A.J8) in main.dart.js');
    }
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Successfully patched main.dart.js');
}

function patchMainDartLive() {
  const filePath = path.join(__dirname, '../main_dart_live.js');
  console.log('Patching', filePath);
  let content = fs.readFileSync(filePath, 'utf8');

  // 1. Ensure vW returns isApproved: true (!0 instead of !1)
  const targetVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!1,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  const replaceVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!0,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  if (!content.includes(targetVw) && !content.includes(replaceVw)) {
    throw new Error('Target vW not found in main_dart_live.js');
  }
  content = content.replace(targetVw, replaceVw);

  // 2. Ensure B.V0 is approved (!0 instead of !1)
  content = content.replace('B.V0=new A.rQ(!1,', 'B.V0=new A.rQ(!0,');

  // 3. Remove blocking check in vo() (Create Profile)
  const targetBlockCreate = /if\(J\.bh\(e\)===0\|\|J\.bh\(d\)===0\|\|J\.bh\(a\)===0\)\{c=n\.c\s*c\.toString\s*A\.bnL\(c\)\s*s=1\s*break\}p=4/;
  if (targetBlockCreate.test(content)) {
    content = content.replace(targetBlockCreate, 'if(!1){}p=4');
    console.log('Removed blocking Details Required check from Create Profile in main_dart_live.js');
  }

  // 4. Remove blocking check in aGN() (Edit Profile)
  const targetBlockEdit = /if\(J\.bh\(m\)===0\|\|J\.bh\(l\)===0\|\|J\.bh\(k\)===0\)\{a1=n\.c\s*a1\.toString\s*A\.bnL\(a1\)\s*s=1\s*break\}p=4/;
  if (targetBlockEdit.test(content)) {
    content = content.replace(targetBlockEdit, 'if(!1){}p=4');
    console.log('Removed blocking Details Required check from Edit Profile in main_dart_live.js');
  }

  // 5. Ensure /advanced-search, /home, and /search routes are defined and in top-level routes
  if (content.includes('b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s)')) {
    if (!content.includes('b_home=')) {
      content = content.replace(
        'b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s)',
        'b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.beY(),"home","/home",s),b_search=A.dv(new A.beZ(),"search","/search",s)'
      );
      console.log('Added b_home and b_search definitions in main_dart_live.js');
    }
  } else {
    const targetRouteDef = 'b1=A.dv(new A.beR(),"search-results","/search-results",s),b2=A.dv(new A.beS(),"candidate-profile-details","/candidate-profile-details",s)';
    const replaceRouteDef = 'b1=A.dv(new A.beR(),"search-results","/search-results",s),b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.beY(),"home","/home",s),b_search=A.dv(new A.beZ(),"search","/search",s),b2=A.dv(new A.beS(),"candidate-profile-details","/candidate-profile-details",s)';
    if (content.includes(targetRouteDef)) {
      content = content.replace(targetRouteDef, replaceRouteDef);
      console.log('Added b_adv, b_home, and b_search definitions in main_dart_live.js');
    }
  }

  // Update top-level route array q
  if (content.includes('b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Added b_home and b_search to top-level routes array in main_dart_live.js');
  } else if (content.includes('b0,b1,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Added b_adv, b_home, and b_search to top-level routes array in main_dart_live.js');
  }

  // 6. Remove IntrinsicHeight from search TextField
  const targetJ8 = 'h=A.h(a6,new A.J8(A.r(A.a([B.bi,B.adB,B.a5,';
  if (content.includes(targetJ8)) {
    const idx = content.indexOf(targetJ8);
    const endPattern = ',B.aM,B.c,B.e,0),a6)';
    const endIdx = content.indexOf(endPattern, idx);
    if (endIdx !== -1 && endIdx - idx < 2000) {
      const before = content.substring(0, idx);
      const middle = content.substring(idx + 'h=A.h(a6,new A.J8('.length, endIdx);
      const after = content.substring(endIdx + endPattern.length);
      content = before + 'h=A.h(a6,' + middle + ',B.aM,B.c,B.e,0)' + after;
      console.log('Removed IntrinsicHeight (new A.J8) in main_dart_live.js');
    }
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Successfully patched main_dart_live.js');
}

function updateCacheBuster() {
  const files = [
    'application/build/web/flutter_bootstrap.js',
    'application/build/web/index.html',
    'application/web/flutter_bootstrap.js',
    'application/web/index.html'
  ];

  for (const relPath of files) {
    const absPath = path.join(__dirname, '..', relPath);
    if (fs.existsSync(absPath)) {
      let content = fs.readFileSync(absPath, 'utf8');
      content = content.replace(/main\.dart\.js\?v=[a-zA-Z0-9_-]+/g, `main.dart.js?v=${VERSION_TAG}`);
      fs.writeFileSync(absPath, content, 'utf8');
      console.log(`Updated cache buster in ${relPath} to v=${VERSION_TAG}`);
    }
  }
}

try {
  patchMainDartJs();
  patchMainDartLive();
  updateCacheBuster();
  console.log('ALL PATCHES APPLIED SUCCESSFULLY!');
} catch (err) {
  console.error('Patching error:', err);
  process.exit(1);
}
