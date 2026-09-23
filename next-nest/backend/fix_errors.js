const fs = require('fs');

// 1. Switch to PostgreSQL
let schema = fs.readFileSync('prisma/schema.prisma', 'utf8');
schema = schema.replace(/provider = "mysql"/, 'provider = "postgresql"');
fs.writeFileSync('prisma/schema.prisma', schema);

// 2. Fix profiles.service.ts
let profilesService = fs.readFileSync('src/profiles/profiles.service.ts', 'utf8');
profilesService = profilesService.replace(/occupationDetail: 'Software Engineer',/, "occupationDetail: 'Software Engineer',\n        organizationName: null,\n        designation: null,");
fs.writeFileSync('src/profiles/profiles.service.ts', profilesService);

// 3. Fix samaj-services.service.ts (add slug)
let samajService = fs.readFileSync('src/samaj-services/samaj-services.service.ts', 'utf8');
samajService = samajService.replace(/category: dto\.category,/g, "category: dto.category,\n      slug: dto.title.toLowerCase().replace(/ /g, '-'),");
fs.writeFileSync('src/samaj-services/samaj-services.service.ts', samajService);

// 4. Fix prisma/seed.ts (add slug)
let seed = fs.readFileSync('prisma/seed.ts', 'utf8');
seed = seed.replace(/category: s\.category,/g, "category: s.category,\n        slug: s.title.toLowerCase().replace(/ /g, '-'),");
fs.writeFileSync('prisma/seed.ts', seed);

console.log("Fixed TS Errors and switched to Postgres");
