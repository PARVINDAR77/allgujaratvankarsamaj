const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(function(file) {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      results = results.concat(walk(file));
    } else {
      if(file.endsWith('.ts') || file.endsWith('.tsx')) {
        results.push(file);
      }
    }
  });
  return results;
}

const files = walk('d:/allgujaratvankarsamaj/next-nest/frontend/src');
let changedFilesCount = 0;

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  const originalContent = content;
  
  // This regex matches from <<<<<<< HEAD to >>>>>>> hash
  // Group 1 captures the HEAD code block
  // Use [\r\n]* to tolerate \r\n vs \n
  const conflictRegex = /<<<<<<< HEAD[\r\n]+([\s\S]*?)=======[\r\n]+[\s\S]*?>>>>>>> [a-f0-9]+[\r\n]*/g;
  
  content = content.replace(conflictRegex, '$1');
  
  if (content !== originalContent) {
    fs.writeFileSync(file, content);
    console.log('Fixed conflicts in ' + file);
    changedFilesCount++;
  }
});

console.log(`Done! Fixed conflicts in ${changedFilesCount} files.`);
