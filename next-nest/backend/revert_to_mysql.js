const fs = require('fs');

// Revert to MySQL
let schema = fs.readFileSync('prisma/schema.prisma', 'utf8');
schema = schema.replace(/provider = "postgresql"/, 'provider = "mysql"');
fs.writeFileSync('prisma/schema.prisma', schema);

// Remove mode: 'insensitive' for MySQL
let profilesService = fs.readFileSync('src/profiles/profiles.service.ts', 'utf8');
profilesService = profilesService.replace(/, mode: 'insensitive'/g, '');
fs.writeFileSync('src/profiles/profiles.service.ts', profilesService);

console.log('Reverted to MySQL and fixed mode errors');
