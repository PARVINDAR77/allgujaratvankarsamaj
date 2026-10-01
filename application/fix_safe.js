const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        if (fs.statSync(dirPath).isDirectory()) {
            walkDir(dirPath, callback);
        } else {
            callback(dirPath);
        }
    });
}

let count = 0;
walkDir('d:\\allgujaratvankarsamaj\\application\\lib', function(filePath) {
    if (filePath.endsWith('.dart')) {
        let content = fs.readFileSync(filePath, 'utf8');
        if (content.includes('<<<<<<< HEAD')) {
            console.log('Fixing ' + filePath);
            let lines = content.split(/\r?\n/);
            let newLines = [];
            let state = 0; // 0: normal, 1: inside HEAD, 2: inside incoming
            
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i];
                if (line.startsWith('<<<<<<< HEAD')) {
                    state = 1;
                    continue;
                } else if (line.startsWith('=======')) {
                    state = 2;
                    continue;
                } else if (line.startsWith('>>>>>>>')) {
                    state = 0;
                    continue;
                }
                
                if (state === 0 || state === 1) {
                    newLines.push(line);
                }
            }
            
            fs.writeFileSync(filePath, newLines.join('\n'), 'utf8');
            count++;
        }
    }
});
console.log('Fixed ' + count + ' files safely.');
