const fs = require('fs');
let content = fs.readFileSync('src/profiles/profiles.service.ts', 'utf8');
content = content.replace(/occupationDetail: 'Software Engineer',\s*annualIncome: null,/g, "occupationDetail: 'Software Engineer',\n        organizationName: null,\n        designation: null,\n        annualIncome: null,");
fs.writeFileSync('src/profiles/profiles.service.ts', content);
console.log('Fixed profiles service');
