const fs = require('fs');
const path = require('path');

const mainDartJsPath = path.join(__dirname, '../application/build/web/main.dart.js');
const mainDartLivePath = path.join(__dirname, '../main_dart_live.js');

console.log('=== Patching Flutter Web Samaj Services Modal ===');

function patchBuildWeb() {
  console.log('Patching', mainDartJsPath);
  let content = fs.readFileSync(mainDartJsPath, 'utf8');

  // 1. Inject A.b7_ProfBtn class definition if not present
  if (!content.includes('b7_ProfBtn:function')) {
    const classDefAnchor = 'b7H:function b7H(a,b,c,d,e,f,g,h,i,j,k,l){var _=this';
    const classDefReplacement = 'b7_ProfBtn:function b7_ProfBtn(a,b,c,d){this.a=a;this.b=b;this.c=c;this.d=d},\nb7H:function b7H(a,b,c,d,e,f,g,h,i,j,k,l,m){var _=this';
    if (content.includes(classDefAnchor)) {
      content = content.replace(classDefAnchor, classDefReplacement);
      // also attach _.P = m
      content = content.replace('_.Q=l}', '_.Q=l;_.P=m}');
      console.log('Added b7_ProfBtn constructor and updated b7H to store provider in _.P');
    } else {
      console.error('ERROR: Could not find classDefAnchor in main.dart.js');
    }

    const protoAnchor = 'A.b7H.prototype={';
    const protoDef = `A.b7_ProfBtn.prototype={
$0(){
  var ctx=this.a,screenState=this.b,phone=this.c,provider=this.d;
  var targetId=phone;
  if(provider&&provider.profileId&&provider.profileId.length>0)targetId=provider.profileId;
  else if(provider&&provider.a&&provider.a.length>0)targetId=provider.a;
  try{A.b8(ctx,!1).bl(null)}catch(e){}
  try{
    var s=screenState?screenState.c:null;
    if(s!=null){s.toString;A.ar(s).b_("/candidate-profile-details?id="+encodeURIComponent(targetId),null,t.X)}
    else{A.ar(ctx).b_("/candidate-profile-details?id="+encodeURIComponent(targetId),null,t.X)}
  }catch(e){
    try{
      if(typeof window!=="undefined"&&window.location){
        window.location.hash="#/candidate-profile-details?id="+encodeURIComponent(targetId);
      }
    }catch(e2){}
  }
  return null
},
$S:0}
A.b7H.prototype={`;
    if (content.includes(protoAnchor)) {
      content = content.replace(protoAnchor, protoDef);
      console.log('Added A.b7_ProfBtn.prototype');
    } else {
      console.error('ERROR: Could not find protoAnchor in main.dart.js');
    }
  }

  // 2. Pass provider `b` to `new A.b7H(...)` in ar0
  const ar0Old = 'return new A.md(new A.b7H(g,this,r,s,n,m,c,l,k,j,i==null?h:i,o),h)},';
  const ar0New = 'return new A.md(new A.b7H(g,this,r,s,n,m,c,l,k,j,i==null?h:i,o,b),h)},';
  if (content.includes(ar0Old)) {
    content = content.replace(ar0Old, ar0New);
    console.log('Passed provider `b` into new A.b7H in ar0');
  }

  // 3. Inject View Candidate Profile button in A.b7H.prototype.$2
  const buttonAnchor = 'o=h.b\nn=h.Q\nf.push(A.r(A.a([A.A(A.bx(B.Fy,B.aOD,new A.b7C(o,n),A.b2(g,g,B.J,g,g,g,g,g,g,B.i,g,g,B.ce,g,new A.ah(A.c(10),B.o),B.fM,g,g,g,g)),1),B.V,A.A(A.bx(B.aXy,B.aUa,new A.b7D(o,n,s,p),A.b2(g,g,B.bt,g,g,g,g,g,g,B.i,g,g,B.ce,g,new A.ah(A.c(10),B.o),g,g,g,g,g)),1)],r),B.h,B.c,B.e,0))';
  
  const buttonInjected = `o=h.b
n=h.Q
f.push(A.r(A.a([A.A(A.bx(new A.x(B.ex,18,B.b3,null,null),new A.n("\\u0a89\\u0aae\\u0ac7\\u0aa6\\u0ab5\\u0abe\\u0ab0 \\u0aaa\\u0acd\\u0ab0\\u0acb\\u0aab\\u0abe\\u0a87\\u0ab2 \\u0a9c\\u0ac1\\u0a93 (View Profile)",null,B.cV,null,null,null,null,null,null,null,null),new A.b7_ProfBtn(a,h.b,h.Q,h.P),A.b2(g,g,B.w,g,g,g,g,g,g,B.i,g,g,B.ce,g,new A.ah(A.c(10),B.o),B.fM,B.tK,g,g,g)),1)],r),B.h,B.c,B.e,0))
f.push(B.S)
f.push(A.r(A.a([A.A(A.bx(B.Fy,B.aOD,new A.b7C(o,n),A.b2(g,g,B.J,g,g,g,g,g,g,B.i,g,g,B.ce,g,new A.ah(A.c(10),B.o),B.fM,g,g,g,g)),1),B.V,A.A(A.bx(B.aXy,B.aUa,new A.b7D(o,n,s,p),A.b2(g,g,B.bt,g,g,g,g,g,g,B.i,g,g,B.ce,g,new A.ah(A.c(10),B.o),g,g,g,g,g)),1)],r),B.h,B.c,B.e,0))`;

  if (content.includes(buttonAnchor)) {
    content = content.replace(buttonAnchor, buttonInjected);
    console.log('Successfully injected View Candidate Profile button into modal in main.dart.js');
  } else if (content.includes('\\u0a89\\u0aae\\u0ac7\\u0aa6\\u0ab5\\u0abe\\u0ab0 \\u0aaa\\u0acd\\u0ab0\\u0acb\\u0aab\\u0abe\\u0a87\\u0ab2 \\u0a9c\\u0ac1\\u0a93 (View Profile)')) {
    console.log('Button is already injected in main.dart.js');
  } else {
    console.error('ERROR: Could not find buttonAnchor in main.dart.js');
  }

  fs.writeFileSync(mainDartJsPath, content, 'utf8');
  console.log('Saved main.dart.js');
}

patchBuildWeb();
console.log('=== Finished Patching ===');
