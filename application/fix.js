const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
    });
}

let count = 0;
walkDir('d:\\allgujaratvankarsamaj\\application\\lib', function(filePath) {
    if (filePath.endsWith('.dart')) {
        let content = fs.readFileSync(filePath, 'utf8');
        if (content.includes('<<<<<<< HEAD')) {
            console.log('Fixing ' + filePath);
            // Replace standard conflicts
            let newContent = content.replace(/<<<<<<< HEAD\r?\n([\s\S]*?)\r?\n=======\r?\n([\s\S]*?)>>>>>>> [^\r\n]+/g, '$1');
            // If the above missed any due to weird newlines:
            newContent = newContent.replace(/<<<<<<< HEAD\r?\n([\s\S]*?)\r?\n=======\r?\n?>>>>>>> [^\r\n]+/g, '$1');
            // And fallback
            newContent = newContent.replace(/<<<<<<< HEAD\n([\s\S]*?)\n=======\n([\s\S]*?)>>>>>>> [^\n]+/g, '$1');
            fs.writeFileSync(filePath, newContent, 'utf8');
            count++;
        }
    }
});
console.log('Fixed ' + count + ' files.');
