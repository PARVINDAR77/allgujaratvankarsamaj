const fs = require('fs');
const file = '/usr/src/app/dist/samaj-services/samaj-services.service.js';
let content = fs.readFileSync(file, 'utf8');

// Find the slug line
const idx = content.indexOf('createService');
const snippet = content.substring(idx, idx + 600);
console.log('Snippet around createService:');
console.log(snippet);
