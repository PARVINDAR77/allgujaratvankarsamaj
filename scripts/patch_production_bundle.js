const fs = require('fs');
const path = require('path');

const VERSION_TAG = '20261104_restore_assets_and_cards_v75';

function patchMainDartJs() {
  const filePath = path.join(__dirname, '../application/build/web/main.dart.js');
  console.log('Patching', filePath);
  let content = fs.readFileSync(filePath, 'utf8');

  // 1. Ensure vW returns isApproved: true (!0 instead of !1)
  const targetVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!1,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  const replaceVw = 'var $async$vW=A.E(function(b5,b6){return A.B(new A.rQ(!0,b2,a9,null,"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0ab8\\u0aab\\u0ab3\\u0aa4\\u0abe\\u0aaa\\u0ac2\\u0ab0\\u0acd\\u0ab5\\u0a95 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7."),r);';
  if (content.includes(targetVw)) {
    content = content.replace(targetVw, replaceVw);
  }

  // 2. Permanently neutralize A.agw (Details Required dialog)
  const targetAgw = 'A.agw.prototype={\n$1(a){var s=null,r=A.d(16)\nreturn A.rS(A.a([A.dB(B.aUC,new A.agv(a),A.b4(s,s,B.n,s,s,s,s,s,s,B.q,s,s,s,s,new A.ah(A.d(8),B.o),s,s,s,s,s))],t.p),B.bJ,B.aSQ,new A.ah(r,B.hq),B.ayG)},';
  const replaceAgw = 'A.agw.prototype={\n$1(a){A.b9(a,!1).bj(null);return B.c0},';
  if (content.includes(targetAgw)) {
    content = content.replace(targetAgw, replaceAgw);
    console.log('Neutralized A.agw dialog in main.dart.js');
  }

  // 3. Permanently neutralize A.agA (Document scanning loading dialog)
  const targetAgA = /A\.agA\.prototype=\{\s*\$1\(a\)\{var s=this,r=null,q=A\.d\(18\)\s*return A\.bke\(!1,A\.jo\(r,B\.bJ,new A\.a_\(B\.a8J,A\.v\(A\.a\(\[B\.aBd,B\.at,B\.aSM,B\.au,B\.aSb,B\.a_,A\.l\(s\.a\?"\\u0a93\\u0ab3\\u0a96\\u0aaa\\u0aa4\\u0acd\\u0ab0 \\u0a85\\u0aaa\\u0ab2\\u0acb\\u0aa1 \\u0aa5\\u0a88 \\u0ab0\\u0ab9\\u0acd\\u0aaf\\u0ac1\\u0a82 \\u0a9b\\u0ac7\.\.\.":/;
  if (targetAgA.test(content)) {
    const startIdx = content.indexOf('A.agA.prototype={');
    const endPattern = '$S:1044}';
    const endIdx = content.indexOf(endPattern, startIdx);
    if (startIdx !== -1 && endIdx !== -1 && endIdx - startIdx < 800) {
      content = content.substring(0, startIdx) + 'A.agA.prototype={\n$1(a){A.b9(a,!1).bj(null);return B.c0},\n' + content.substring(endIdx);
      console.log('Neutralized A.agA loading dialog in main.dart.js');
    }
  }

  // 4. Revert any extra top-level route definitions to eliminate duplicate route collision ("Route not found: /home")
  const defPattern = 'b1=A.dv(new A.beT(),"search-results","/search-results",s),b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.bf_(),"home","/home",s),b_search=A.dv(new A.bf0(),"search","/search",s),b2=A.dv(new A.beU(),';
  const cleanDef = 'b1=A.dv(new A.beT(),"search-results","/search-results",s),b2=A.dv(new A.beU(),';
  if (content.includes(defPattern)) {
    content = content.replace(defPattern, cleanDef);
    console.log('Cleaned top-level route definitions in main.dart.js');
  }

  const defPatternAdvOnly = 'b1=A.dv(new A.beT(),"search-results","/search-results",s),b_adv=A.dv(new A.bf1(),"advanced-search","/advanced-search",s),b2=A.dv(new A.beU(),';
  if (content.includes(defPatternAdvOnly)) {
    content = content.replace(defPatternAdvOnly, cleanDef);
    console.log('Cleaned b_adv route definition in main.dart.js');
  }

  if (content.includes('b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Restored clean top-level routes array in main.dart.js');
  } else if (content.includes('b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Restored clean top-level routes array in main.dart.js');
  }

  // 5. Remove IntrinsicHeight from search TextField
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

  // 6. Neutralize legacy min 2 candidate photos check (d < 2) in Create Profile
  const targetMinPhotos = 'if(d<2){n.c.N(t.q).f.aQ(B.aBZ)';
  if (content.includes(targetMinPhotos)) {
    content = content.replace(targetMinPhotos, 'if(!1){n.c.N(t.q).f.aQ(B.aBZ)');
    console.log('Neutralized min 2 photos check in main.dart.js');
  }

  // 7. STRICT PHOTO LIMIT: Force SINGLE image picker in Create Profile (disable pickMultiImage)
  const createPickerTarget = /case 0:d=n\.x\s*if\(d\.length>=5\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}p=4\s*f=n\.db\s*s=7\s*return A\.t\(f\.L_\(\),\$async\$rO\)/;
  if (createPickerTarget.test(content)) {
    content = content.replace(createPickerTarget, (match, errConst) => {
      return `case 0:d=n.x\nif(d.length>=1){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}p=4\nf=n.db\ns=10\nbreak`;
    });
    console.log('Enforced single image picker & max 1 sub photo in Create Profile (main.dart.js)');
  }
  const createCase17 = /case 17:h=b\s*if\(J\.bh\(h\)>5242880\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}if\(d\.length<5\)/;
  if (createCase17.test(content)) {
    content = content.replace(createCase17, (match, errConst) => {
      return `case 17:h=b\nif(J.bh(h)>5242880){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}if(d.length<1)`;
    });
    console.log('Capped Create Profile case 17 to d.length < 1 (main.dart.js)');
  }

  // 8. STRICT PHOTO LIMIT: Force SINGLE image picker in Edit Profile (disable pickMultiImage)
  const editPickerTarget = /case 0:d=n\.y\s*if\(n\.x\.length\+d\.length>=5\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}p=4\s*f=n\.fr\s*s=7\s*return A\.t\(f\.L_\(\),\$async\$t0\)/;
  if (editPickerTarget.test(content)) {
    content = content.replace(editPickerTarget, (match, errConst) => {
      return `case 0:d=n.y\nif(n.x.length+d.length>=1){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}p=4\nf=n.fr\ns=10\nbreak`;
    });
    console.log('Enforced single image picker & max 1 sub photo in Edit Profile (main.dart.js)');
  }
  const editCase17 = /case 17:h=b\s*if\(J\.bh\(h\)>5242880\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}if\(n\.x\.length\+d\.length<5\)/;
  if (editCase17.test(content)) {
    content = content.replace(editCase17, (match, errConst) => {
      return `case 17:h=b\nif(J.bh(h)>5242880){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}if(n.x.length+d.length<1)`;
    });
    console.log('Capped Edit Profile case 17 to n.x.length+d.length < 1 (main.dart.js)');
  }

  // 9. UI: Limit counters and hide "Add Photo" button once 1 sub photo is added
  content = content.replace(/d\+" \/ 5"/g, 'd+" / 1"');
  content = content.replace(/c\+" \/ 5"/g, 'c+" / 1"');
  content = content.replace(/if\(g<5\)\{n=A\.d\(12\)/g, 'if(g<1){n=A.d(12)');
  content = content.replace(/if\(l<5\)\{m=A\.d\(12\)/g, 'if(l<1){m=A.d(12)');

  // 10. UI: Replace warning text ("Please add more photos") with optional sub photo message
  const createUiText = /h=m<2\s*if\(h\)\{g=""+(?:\(2-m\)|2-m)\s*g="\\u26a0\\ufe0f[^\"]+"\+g\+"[^\"]+"\}else g="\\u2713[^\"]+"\+d\+"[^\"]+"\+(?:\(5-m\)|5-m)\+"[^\"]+"/;
  if (createUiText.test(content)) {
    content = content.replace(createUiText, 'h=!1\ng=m===0?"\\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u0a9b\\u0ac7 (\\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 - Sub Photo Optional)":"\\u2713 \\u0ae7 \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0aaa\\u0ab8\\u0a82\\u0aa6 \\u0aa5\\u0aaf\\u0ac7\\u0ab2 \\u0a9b\\u0ac7 (1 Sub Photo Selected)"');
    console.log('Updated Create Profile UI status text in main.dart.js');
  }

  const editUiText = /g=l<2\s*if\(g\)\{f=""+(?:\(2-l\)|2-l)\s*f="\\u26a0\\ufe0f[^\"]+"\+f\+"[^\"]+"\}else f="\\u2713[^\"]+"\+c\+"[^\"]+"\+(?:\(5-l\)|5-l)\+"[^\"]+"/;
  if (editUiText.test(content)) {
    content = content.replace(editUiText, 'g=!1\nf=l===0?"\\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u0a9b\\u0ac7 (\\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 - Sub Photo Optional)":"\\u2713 \\u0ae7 \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0aaa\\u0ab8\\u0a82\\u0aa6 \\u0aa5\\u0aaf\\u0ac7\\u0ab2 \\u0a9b\\u0ac7 (1 Sub Photo Selected)"');
    console.log('Updated Edit Profile UI status text in main.dart.js');
  }

  // 11. Header Text Constants: Rename Candidate Photos box to Sub Photo (Optional, Max 1)
  content = content.replace(
    'B.aSE=new A.n("Candidate Photos / \\u0a89\\u0aae\\u0ac7\\u0aa6\\u0ab5\\u0abe\\u0ab0\\u0aa8\\u0abe \\u0aab\\u0acb\\u0a9f\\u0abe (\\u0ae8 \\u0aa5\\u0ac0 \\u0aeb \\u0aab\\u0acb\\u0a9f\\u0acb)"',
    'B.aSE=new A.n("Sub Photo / \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb (\\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u2022 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7)"'
  );
  content = content.replace(
    'B.aNA=new A.n("\\u0a93\\u0a9b\\u0abe\\u0aae\\u0abe\\u0a82 \\u0a93\\u0a9b\\u0abe \\u0ae8 \\u0a85\\u0aa8\\u0ac7 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0aeb \\u0aab\\u0acb\\u0a9f\\u0acb (Min 2, Max 5 \\u2022 Max 5 MB each)"',
    'B.aNA=new A.n("\\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u2022 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 \\u0aab\\u0acb\\u0a9f\\u0acb (Optional \\u2022 Max 1 Photo \\u2022 Max 5 MB)"'
  );

  // 12. Enable Click-to-Zoom Lightbox for Samaj Super Stars & Samaj Ratna
  const b0EStart = content.indexOf('A.b0E.prototype={');
  if (b0EStart !== -1) {
    const b0EEnd = content.indexOf('$S:0}', b0EStart);
    if (b0EEnd !== -1 && b0EEnd - b0EStart < 200) {
      const fullB0E = content.substring(b0EStart, b0EEnd + 5);
      const newB0E = 'A.b0E.prototype={\n$0(){var s=this.b,r=this.a,q=this.c;\nif(s&&s.d!=null&&s.d.length!==0){\n  var u=s.c;\n  if((u==null?null:u.length!==0)===!0){u.toString; u=u;} else u=s.b;\n  A.fl(null,B.a2p,!0,null,new A.b0O(s,u),q,null,!0,t.z);\n} else if(r&&r.a7z) {\n  r.a7z(q,s);\n} else if(r&&r.aK0) {\n  r.aK0(q,s);\n} else if(r&&r.aJR) {\n  r.aJR(q,s);\n}\n},\n$S:0}';
      content = content.substring(0, b0EStart) + newB0E + content.substring(b0EEnd + 5);
      console.log('Upgraded A.b0E to universal click-to-zoom photo lightbox in main.dart.js');
    }
  }

  // Samaj Super Stars avatar click-to-zoom
  const starAvatarTarget = 'o=A.a([A.h(f,A.h(f,A.f1(g.ar9(b)),B.f,f,f,B.oi,f,f,f,f,f,f,f),B.f,f,f,new A.j(f,f,f,f,o,B.kJ,B.F),f,112,f,B.hG,f,f,112),B.N,A.l(r,2,B.D,f,f,B.aJx,B.H,f,f)],m)';
  const starAvatarReplace = 'o=A.a([A.b_(!1,A.d(60),!0,A.h(f,A.h(f,A.f1(g.ar9(b)),B.f,f,f,B.oi,f,f,f,f,f,f,f),B.f,f,f,new A.j(f,f,f,f,o,B.kJ,B.F),f,112,f,B.hG,f,f,112),f,!0,f,f,f,f,f,f,f,f,f,f,new A.b0E(g,b,a),f,f,f,f,f,f,f),B.N,A.l(r,2,B.D,f,f,B.aJx,B.H,f,f)],m)';
  if (content.includes(starAvatarTarget)) {
    content = content.replace(starAvatarTarget, starAvatarReplace);
    console.log('Wrapped Samaj Super Stars avatar with click-to-zoom InkWell in main.dart.js');
  }

  // Samaj Ratna avatar click-to-zoom
  const ratnaAvatarTarget = ',104),i.aqY(b)],j),B.x,B.ax,h),h,h)';
  const ratnaAvatarReplace = ',104),A.b_(!1,A.d(50),!0,i.aqY(b),h,!0,h,h,h,h,h,h,h,h,h,h,new A.b0E(i,b,a),h,h,h,h,h,h,h)],j),B.x,B.ax,h),h,h)';
  if (content.includes(ratnaAvatarTarget)) {
    content = content.replace(ratnaAvatarTarget, ratnaAvatarReplace);
    console.log('Wrapped Samaj Ratna avatar with click-to-zoom InkWell in main.dart.js');
  }

  // 13. Remove Buddha and Ambedkar Reverence Tag Lines below artwork cards
  const targetBuddhaTag = 'A.v(A.a([o,B.Y,A.h(s,B.axV,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.6),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.fm,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetBuddhaTag)) {
    content = content.replace(targetBuddhaTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Buddha tag line from web home hero in main.dart.js');
  }

  const targetAmbedkarTag = 'A.v(A.a([o,B.Y,A.h(s,B.ayi,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.6),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.fm,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetAmbedkarTag)) {
    content = content.replace(targetAmbedkarTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Ambedkar tag line from web home hero in main.dart.js');
  }

  const targetMatrimonyBuddhaTag = 'A.v(A.a([o,B.aO,A.h(s,B.axN,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.7),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.a96,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetMatrimonyBuddhaTag)) {
    content = content.replace(targetMatrimonyBuddhaTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Buddha tag line from web matrimony hero in main.dart.js');
  }

  // 14. Fix Route not found: /home (Header and Footer Nav Links)
  const navLinkPattern = 'if(s==="/main-poster")A.au(r).by(0,"/main-poster",null)\nelse A.au(r).b4(s,null,t.X)';
  const navLinkReplace = 'if(s==="/main-poster"||s==="/home")A.au(r).by(0,s,null)\nelse A.au(r).b4(s,null,t.X)';
  if (content.includes(navLinkPattern)) {
    content = content.replaceAll(navLinkPattern, navLinkReplace);
    console.log('Fixed Header & Footer navigation links to use context.go(/home) in main.dart.js');
  }

  // 15. Redesign Prominent Community Portals to Royal Gold Artworks (Compact & Centered 270x438)
  const portalCardTargetOld = 'A.a6u.prototype={\nK(a){var s,r,q,p,o,n,m,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-5:0,0),h=A.d(18),g=l.d,f=g?B.w:B.bP\nf=A.w(f,B.j,g?1.8:1.2)\ng=g?B.w.u(0.2):B.q.u(0.06)\ns=l.d\nr=s?20:10\ns=s?8:4\nq=t.V\nr=A.a([new A.a2(0,B.t,g,new A.p(0,s),r)],q)\ns=A.d(18)\ng=A.w(B.cO,B.j,1.8)\np=A.a([new A.a2(0,B.t,B.w.u(0.45),B.aD,10)],q)\np=A.h(k,A.aD(A.ay(j.f,B.dP,k,k,28),k,k),B.f,k,k,new A.j(k,k,g,k,p,B.akc,B.F),k,62,k,k,k,k,62)\ng=A.l(j.a+". "+j.b,k,k,k,k,B.aIf,B.H,k,k)\no=A.l(j.c,k,k,k,k,B.aJk,B.H,k,k)\nn=A.l(j.d,3,B.D,k,k,B.Tt,B.H,k,k)\nm=A.d(10)\nreturn A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,new A.a_(B.kc,A.v(A.a([p,B.N,g,B.rl,o,B.aO,new A.bi(B.AH,n,k),B.bb,A.h(k,B.axX,B.f,k,k,new A.j(B.w,k,A.w(B.E,B.j,1),m,A.a([new A.a2(0,B.t,B.w.u(0.35),B.aD,8)],q),k,B.k),k,k,k,B.cj,k,k,1/0)],t.p),B.h,B.c,B.y),k),k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,k,k,k,i,k),B.cG,k,new A.aUh(l),new A.aUi(l),k)}}';
  const portalCardTargetV74 = 'A.a6u.prototype={\nK(a){var s,r,q=t.V,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-8:0,0),h=A.d(22),f=A.w(l.d?B.cO:B.E,B.j,l.d?2.5:1.5)\nr=A.a([new A.a2(0,B.t,l.d?B.cO.u(0.35):B.q.u(0.15),new A.p(0,l.d?10:5),l.d?24:12)],q)\ns=A.d(20)\nvar img=j.a==="1"?"assets/images/portal_card_prernadata.png":(j.a==="2"?"assets/images/portal_card_superstars.png":"assets/images/portal_card_ratna.png");\nvar cardImg=A.f2(s,new A.rY(160/260,A.cw(img,B.z,k,k,new A.bc3(),B.aw,k,k),k),B.aG);\nreturn A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,cardImg,k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,k,k,k,i,k),B.cG,k,new A.aUh(l),new A.aUi(l),k)}}';
  const newCardImpl = 'A.a6u.prototype={\nK(a){var s,r,q=t.V,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-8:0,0),h=A.d(20),f=A.w(l.d?B.cO:B.E,B.j,l.d?2.5:1.5)\nr=A.a([new A.a2(0,B.t,l.d?B.cO.u(0.35):B.q.u(0.15),new A.p(0,l.d?10:5),l.d?24:12)],q)\ns=A.d(18)\nvar img=j.a==="1"?"assets/images/portal_card_prernadata.png":(j.a==="2"?"assets/images/portal_card_superstars.png":"assets/images/portal_card_ratna.png");\nvar cardImg=A.f2(s,A.cw(img,B.z,k,k,new A.bc3(),B.aw,270,438),B.aG);\nreturn A.aD(A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,cardImg,k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,438,k,k,i,270),B.cG,k,new A.aUh(l),new A.aUi(l),k),k,k)}}';

  if (content.includes(portalCardTargetV74)) {
    content = content.replace(portalCardTargetV74, newCardImpl);
    console.log('Updated portal cards to compact 270x438 centered cards in main.dart.js');
  } else if (content.includes(portalCardTargetOld)) {
    content = content.replace(portalCardTargetOld, newCardImpl);
    console.log('Upgraded portal cards to compact 270x438 centered cards in main.dart.js');
  }

  // 16. Dynamic Asset Manifest resolver for portal cards (leaves AssetManifest.bin.json 100% clean)
  const targetAhe = 'if(r.h(s,a)==null)return null';
  const replaceAhe = 'if(r.h(s,a)==null){if(typeof a==="string"&&a.indexOf("assets/images/portal_card_")===0){var v=A.a([new A.rZ(null,a)],t.pE);p.p(0,a,v);return v}return null}';
  if (content.includes(targetAhe)) {
    content = content.replace(targetAhe, replaceAhe);
    console.log('Added dynamic asset fallback in main.dart.js');
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
  if (content.includes(targetVw)) {
    content = content.replace(targetVw, replaceVw);
  }

  // 2. Permanently neutralize A.agw (Details Required dialog)
  const targetAgwLive = 'A.agw.prototype={\n$1(a){var s=null,r=A.d(16)\nreturn A.rS(A.a([A.dB(B.aUB,new A.agv(a),A.b4(s,s,B.n,s,s,s,s,s,s,B.q,s,s,s,s,new A.ah(A.d(8),B.o),s,s,s,s,s))],t.p),B.bJ,B.aSP,new A.ah(r,B.hq),B.ayF)},';
  const replaceAgwLive = 'A.agw.prototype={\n$1(a){A.b9(a,!1).bj(null);return B.c0},';
  if (content.includes(targetAgwLive)) {
    content = content.replace(targetAgwLive, replaceAgwLive);
    console.log('Neutralized A.agw dialog in main_dart_live.js');
  }

  // 3. Permanently neutralize A.agA (Document scanning loading dialog)
  const startIdxLive = content.indexOf('A.agA.prototype={');
  if (startIdxLive !== -1) {
    const endPatternLive = '$S:1044}';
    const endIdxLive = content.indexOf(endPatternLive, startIdxLive);
    if (endIdxLive !== -1 && endIdxLive - startIdxLive < 800) {
      content = content.substring(0, startIdxLive) + 'A.agA.prototype={\n$1(a){A.b9(a,!1).bj(null);return B.c0},\n' + content.substring(endIdxLive);
      console.log('Neutralized A.agA loading dialog in main_dart_live.js');
    }
  }

  // 4. Ensure B.V0 is approved (!0 instead of !1)
  content = content.replace('B.V0=new A.rQ(!1,', 'B.V0=new A.rQ(!0,');

  // 5. Remove blocking check in vo() (Create Profile)
  const targetBlockCreate = /if\(J\.bh\(e\)===0\|\|J\.bh\(d\)===0\|\|J\.bh\(a\)===0\)\{c=n\.c\s*c\.toString\s*A\.bnL\(c\)\s*s=1\s*break\}p=4/;
  if (targetBlockCreate.test(content)) {
    content = content.replace(targetBlockCreate, 'if(!1){}p=4');
    console.log('Removed blocking Details Required check from Create Profile in main_dart_live.js');
  }

  // 6. Remove blocking check in aGN() (Edit Profile)
  const targetBlockEdit = /if\(J\.bh\(m\)===0\|\|J\.bh\(l\)===0\|\|J\.bh\(k\)===0\)\{a1=n\.c\s*a1\.toString\s*A\.bnL\(a1\)\s*s=1\s*break\}p=4/;
  if (targetBlockEdit.test(content)) {
    content = content.replace(targetBlockEdit, 'if(!1){}p=4');
    console.log('Removed blocking Details Required check from Edit Profile in main_dart_live.js');
  }

  // 7. Revert extra top-level route definitions to eliminate duplicate route collision ("Route not found: /home")
  const defPatternLive = 'b1=A.dv(new A.beR(),"search-results","/search-results",s),b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s),b_home=A.dv(new A.beY(),"home","/home",s),b_search=A.dv(new A.beZ(),"search","/search",s),b2=A.dv(new A.beS(),';
  const cleanDefLive = 'b1=A.dv(new A.beR(),"search-results","/search-results",s),b2=A.dv(new A.beS(),';
  if (content.includes(defPatternLive)) {
    content = content.replace(defPatternLive, cleanDefLive);
    console.log('Cleaned top-level route definitions in main_dart_live.js');
  }

  const defPatternLiveAdvOnly = 'b1=A.dv(new A.beR(),"search-results","/search-results",s),b_adv=A.dv(new A.bf_(),"advanced-search","/advanced-search",s),b2=A.dv(new A.beS(),';
  if (content.includes(defPatternLiveAdvOnly)) {
    content = content.replace(defPatternLiveAdvOnly, cleanDefLive);
    console.log('Cleaned b_adv route definition in main_dart_live.js');
  }

  if (content.includes('b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b_home,b_search,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Restored clean top-level routes array in main_dart_live.js');
  } else if (content.includes('b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(')) {
    content = content.replace(
      'b0,b1,b_adv,b2,b3,b4,b5,b6,new A.yL(',
      'b0,b1,b2,b3,b4,b5,b6,new A.yL('
    );
    console.log('Restored clean top-level routes array in main_dart_live.js');
  }

  // 8. Remove IntrinsicHeight from search TextField
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

  // 9. Neutralize legacy min 2 candidate photos check (d < 2) in Create Profile
  const targetMinPhotos = 'if(d<2){n.c.N(t.q).f.aQ(B.aBZ)';
  if (content.includes(targetMinPhotos)) {
    content = content.replace(targetMinPhotos, 'if(!1){n.c.N(t.q).f.aQ(B.aBZ)');
    console.log('Neutralized min 2 photos check in main_dart_live.js');
  }

  // 10. STRICT PHOTO LIMIT: Force SINGLE image picker in Create Profile (disable pickMultiImage)
  const createPickerTarget = /case 0:d=n\.x\s*if\(d\.length>=5\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}p=4\s*f=n\.db\s*s=7\s*return A\.t\(f\.L_\(\),\$async\$rO\)/;
  if (createPickerTarget.test(content)) {
    content = content.replace(createPickerTarget, (match, errConst) => {
      return `case 0:d=n.x\nif(d.length>=1){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}p=4\nf=n.db\ns=10\nbreak`;
    });
    console.log('Enforced single image picker & max 1 sub photo in Create Profile (main_dart_live.js)');
  }
  const createCase17 = /case 17:h=b\s*if\(J\.bh\(h\)>5242880\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}if\(d\.length<5\)/;
  if (createCase17.test(content)) {
    content = content.replace(createCase17, (match, errConst) => {
      return `case 17:h=b\nif(J.bh(h)>5242880){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}if(d.length<1)`;
    });
    console.log('Capped Create Profile case 17 to d.length < 1 (main_dart_live.js)');
  }

  // 11. STRICT PHOTO LIMIT: Force SINGLE image picker in Edit Profile (disable pickMultiImage)
  const editPickerTarget = /case 0:d=n\.y\s*if\(n\.x\.length\+d\.length>=5\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}p=4\s*f=n\.fr\s*s=7\s*return A\.t\(f\.L_\(\),\$async\$t0\)/;
  if (editPickerTarget.test(content)) {
    content = content.replace(editPickerTarget, (match, errConst) => {
      return `case 0:d=n.y\nif(n.x.length+d.length>=1){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}p=4\nf=n.fr\ns=10\nbreak`;
    });
    console.log('Enforced single image picker & max 1 sub photo in Edit Profile (main_dart_live.js)');
  }
  const editCase17 = /case 17:h=b\s*if\(J\.bh\(h\)>5242880\)\{n\.c\.N\(t\.q\)\.f\.aQ\(([^)]+)\)\s*s=1\s*break\}if\(n\.x\.length\+d\.length<5\)/;
  if (editCase17.test(content)) {
    content = content.replace(editCase17, (match, errConst) => {
      return `case 17:h=b\nif(J.bh(h)>5242880){n.c.N(t.q).f.aQ(${errConst})\ns=1\nbreak}if(n.x.length+d.length<1)`;
    });
    console.log('Capped Edit Profile case 17 to n.x.length+d.length < 1 (main_dart_live.js)');
  }

  // 12. UI: Limit counters and hide "Add Photo" button once 1 sub photo is added
  content = content.replace(/d\+" \/ 5"/g, 'd+" / 1"');
  content = content.replace(/c\+" \/ 5"/g, 'c+" / 1"');
  content = content.replace(/if\(g<5\)\{n=A\.d\(12\)/g, 'if(g<1){n=A.d(12)');
  content = content.replace(/if\(l<5\)\{m=A\.d\(12\)/g, 'if(l<1){m=A.d(12)');

  // 13. UI: Replace warning text ("Please add more photos") with optional sub photo message
  const createUiText = /h=m<2\s*if\(h\)\{g=""+(?:\(2-m\)|2-m)\s*g="\\u26a0\\ufe0f[^\"]+"\+g\+"[^\"]+"\}else g="\\u2713[^\"]+"\+d\+"[^\"]+"\+(?:\(5-m\)|5-m)\+"[^\"]+"/;
  if (createUiText.test(content)) {
    content = content.replace(createUiText, 'h=!1\ng=m===0?"\\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u0a9b\\u0ac7 (\\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 - Sub Photo Optional)":"\\u2713 \\u0ae7 \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0aaa\\u0ab8\\u0a82\\u0aa6 \\u0aa5\\u0aaf\\u0ac7\\u0ab2 \\u0a9b\\u0ac7 (1 Sub Photo Selected)"');
    console.log('Updated Create Profile UI status text in main_dart_live.js');
  }

  const editUiText = /g=l<2\s*if\(g\)\{f=""+(?:\(2-l\)|2-l)\s*f="\\u26a0\\ufe0f[^\"]+"\+f\+"[^\"]+"\}else f="\\u2713[^\"]+"\+c\+"[^\"]+"\+(?:\(5-l\)|5-l)\+"[^\"]+"/;
  if (editUiText.test(content)) {
    content = content.replace(editUiText, 'g=!1\nf=l===0?"\\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u0a9b\\u0ac7 (\\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 - Sub Photo Optional)":"\\u2713 \\u0ae7 \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb \\u0aaa\\u0ab8\\u0a82\\u0aa6 \\u0aa5\\u0aaf\\u0ac7\\u0ab2 \\u0a9b\\u0ac7 (1 Sub Photo Selected)"');
    console.log('Updated Edit Profile UI status text in main_dart_live.js');
  }

  // 14. Header Text Constants: Rename Candidate Photos box to Sub Photo (Optional, Max 1)
  content = content.replace(
    'B.aSD=new A.n("Candidate Photos / \\u0a89\\u0aae\\u0ac7\\u0aa6\\u0ab5\\u0abe\\u0ab0\\u0aa8\\u0abe \\u0aab\\u0acb\\u0a9f\\u0abe (\\u0ae8 \\u0aa5\\u0ac0 \\u0aeb \\u0aab\\u0acb\\u0a9f\\u0acb)"',
    'B.aSD=new A.n("Sub Photo / \\u0a97\\u0acc\\u0aa3 \\u0aab\\u0acb\\u0a9f\\u0acb (\\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u2022 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7)"'
  );
  content = content.replace(
    'B.aNz=new A.n("\\u0a93\\u0a9b\\u0abe\\u0aae\\u0abe\\u0a82 \\u0a93\\u0a9b\\u0abe \\u0ae8 \\u0a85\\u0aa8\\u0ac7 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0aeb \\u0aab\\u0acb\\u0a9f\\u0acb (Min 2, Max 5 \\u2022 Max 5 MB each)"',
    'B.aNz=new A.n("\\u0ab5\\u0ac8\\u0a95\\u0ab2\\u0acd\\u0aaa\\u0abf\\u0a95 \\u2022 \\u0ab5\\u0aa7\\u0ac1\\u0aae\\u0abe\\u0a82 \\u0ab5\\u0aa7\\u0ac1 \\u0ae7 \\u0aab\\u0acb\\u0a9f\\u0acb (Optional \\u2022 Max 1 Photo \\u2022 Max 5 MB)"'
  );

  // 15. Fix Route not found: /home (Header and Footer Nav Links)
  const navLinkPattern = 'if(s==="/main-poster")A.au(r).by(0,"/main-poster",null)\nelse A.au(r).b4(s,null,t.X)';
  const navLinkReplace = 'if(s==="/main-poster"||s==="/home")A.au(r).by(0,s,null)\nelse A.au(r).b4(s,null,t.X)';
  if (content.includes(navLinkPattern)) {
    content = content.replaceAll(navLinkPattern, navLinkReplace);
    console.log('Fixed Header & Footer navigation links to use context.go(/home) in main_dart_live.js');
  }

  // 16. Redesign Prominent Community Portals to Royal Gold Artworks (Compact & Centered 270x438)
  const portalCardTargetOld = 'A.a6u.prototype={\nK(a){var s,r,q,p,o,n,m,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-5:0,0),h=A.d(18),g=l.d,f=g?B.w:B.bP\nf=A.w(f,B.j,g?1.8:1.2)\ng=g?B.w.u(0.2):B.q.u(0.06)\ns=l.d\nr=s?20:10\ns=s?8:4\nq=t.V\nr=A.a([new A.a2(0,B.t,g,new A.p(0,s),r)],q)\ns=A.d(18)\ng=A.w(B.cO,B.j,1.8)\np=A.a([new A.a2(0,B.t,B.w.u(0.45),B.aD,10)],q)\np=A.h(k,A.aD(A.ay(j.f,B.dP,k,k,28),k,k),B.f,k,k,new A.j(k,k,g,k,p,B.akc,B.F),k,62,k,k,k,k,62)\ng=A.l(j.a+". "+j.b,k,k,k,k,B.aIf,B.H,k,k)\no=A.l(j.c,k,k,k,k,B.aJk,B.H,k,k)\nn=A.l(j.d,3,B.D,k,k,B.Tt,B.H,k,k)\nm=A.d(10)\nreturn A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,new A.a_(B.kc,A.v(A.a([p,B.N,g,B.rl,o,B.aO,new A.bi(B.AH,n,k),B.bb,A.h(k,B.axX,B.f,k,k,new A.j(B.w,k,A.w(B.E,B.j,1),m,A.a([new A.a2(0,B.t,B.w.u(0.35),B.aD,8)],q),k,B.k),k,k,k,B.cj,k,k,1/0)],t.p),B.h,B.c,B.y),k),k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,k,k,k,i,k),B.cG,k,new A.aUh(l),new A.aUi(l),k)}}';
  const portalCardTargetV74 = 'A.a6u.prototype={\nK(a){var s,r,q=t.V,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-8:0,0),h=A.d(22),f=A.w(l.d?B.cO:B.E,B.j,l.d?2.5:1.5)\nr=A.a([new A.a2(0,B.t,l.d?B.cO.u(0.35):B.q.u(0.15),new A.p(0,l.d?10:5),l.d?24:12)],q)\ns=A.d(20)\nvar img=j.a==="1"?"assets/images/portal_card_prernadata.png":(j.a==="2"?"assets/images/portal_card_superstars.png":"assets/images/portal_card_ratna.png");\nvar cardImg=A.f2(s,new A.rY(160/260,A.cw(img,B.z,k,k,new A.bc3(),B.aw,k,k),k),B.aG);\nreturn A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,cardImg,k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,k,k,k,i,k),B.cG,k,new A.aUh(l),new A.aUi(l),k)}}';
  const newCardImpl = 'A.a6u.prototype={\nK(a){var s,r,q=t.V,l=this,k=null,j=l.a.c,i=A.jA(0,l.d?-8:0,0),h=A.d(20),f=A.w(l.d?B.cO:B.E,B.j,l.d?2.5:1.5)\nr=A.a([new A.a2(0,B.t,l.d?B.cO.u(0.35):B.q.u(0.15),new A.p(0,l.d?10:5),l.d?24:12)],q)\ns=A.d(18)\nvar img=j.a==="1"?"assets/images/portal_card_prernadata.png":(j.a==="2"?"assets/images/portal_card_superstars.png":"assets/images/portal_card_ratna.png");\nvar cardImg=A.f2(s,A.cw(img,B.z,k,k,new A.bc3(),B.aw,270,438),B.aG);\nreturn A.aD(A.eE(A.hP(k,A.cE(!1,B.P,!0,k,A.b_(!1,s,!0,cardImg,k,!0,k,k,k,k,k,k,k,k,k,k,new A.aUg(a,j),k,k,k,k,k,k,k),B.f,B.B,0,k,k,k,k,k,B.b5),k,B.cP,new A.j(B.i,k,f,h,r,k,B.k),B.pn,k,438,k,k,i,270),B.cG,k,new A.aUh(l),new A.aUi(l),k),k,k)}}';

  if (content.includes(portalCardTargetV74)) {
    content = content.replace(portalCardTargetV74, newCardImpl);
    console.log('Updated portal cards to compact 270x438 centered cards in main_dart_live.js');
  } else if (content.includes(portalCardTargetOld)) {
    content = content.replace(portalCardTargetOld, newCardImpl);
    console.log('Upgraded portal cards to compact 270x438 centered cards in main_dart_live.js');
  }

  // 17. Dynamic Asset Manifest resolver for portal cards (leaves AssetManifest.bin.json 100% clean)
  const targetAhe = 'if(r.h(s,a)==null)return null';
  const replaceAhe = 'if(r.h(s,a)==null){if(typeof a==="string"&&a.indexOf("assets/images/portal_card_")===0){var v=A.a([new A.rZ(null,a)],t.pE);p.p(0,a,v);return v}return null}';
  if (content.includes(targetAhe)) {
    content = content.replace(targetAhe, replaceAhe);
    console.log('Added dynamic asset fallback in main_dart_live.js');
  }

  // 17. Remove Buddha and Ambedkar Reverence Tag Lines below artwork cards
  const targetBuddhaTag = 'A.v(A.a([o,B.Y,A.h(s,B.axV,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.6),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.fm,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetBuddhaTag)) {
    content = content.replace(targetBuddhaTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Buddha tag line from web home hero in main_dart_live.js');
  }

  const targetAmbedkarTag = 'A.v(A.a([o,B.Y,A.h(s,B.ayi,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.6),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.fm,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetAmbedkarTag)) {
    content = content.replace(targetAmbedkarTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Ambedkar tag line from web home hero in main_dart_live.js');
  }

  const targetMatrimonyBuddhaTag = 'A.v(A.a([o,B.aO,A.h(s,B.axN,B.f,s,s,new A.j(B.a6,s,A.w(B.E.u(0.7),B.j,1),q,A.a([new A.a2(0,B.t,B.I.u(0.04),B.cn,4)],p),s,B.k),s,s,s,B.a96,s,s,s)],l),B.h,B.c,B.y)';
  if (content.includes(targetMatrimonyBuddhaTag)) {
    content = content.replace(targetMatrimonyBuddhaTag, 'A.v(A.a([o],l),B.h,B.c,B.y)');
    console.log('Removed Buddha tag line from web matrimony hero in main_dart_live.js');
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Successfully patched main_dart_live.js');
}

function updateCacheBuster() {
  const htmlFiles = [
    'application/build/web/index.html',
    'application/web/index.html'
  ];

  for (const relPath of htmlFiles) {
    const absPath = path.join(__dirname, '..', relPath);
    if (fs.existsSync(absPath)) {
      let content = fs.readFileSync(absPath, 'utf8');
      content = content.replace(/var CURRENT_BUILD = '[^']+';/g, `var CURRENT_BUILD = '${VERSION_TAG}';`);
      content = content.replace(/flutter_bootstrap\.js\?v=[a-zA-Z0-9_-]+/g, `flutter_bootstrap.js?v=${VERSION_TAG}`);
      fs.writeFileSync(absPath, content, 'utf8');
      console.log(`Updated cache buster in ${relPath} to v=${VERSION_TAG}`);
    }
  }

  const jsFiles = [
    'application/build/web/flutter_bootstrap.js',
    'application/web/flutter_bootstrap.js'
  ];

  for (const relPath of jsFiles) {
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
  console.log('ALL RESTORED ASSETS & COMPACT CARDS PATCHES APPLIED SUCCESSFULLY!');
} catch (err) {
  console.error('Patching error:', err);
  process.exit(1);
}
