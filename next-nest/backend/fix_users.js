const bcrypt = require('bcrypt');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addPersistentUsers() {
  const hash = await bcrypt.hash('password123', 10);
  
  await prisma.user.upsert({
    where: { email: 'admin@vankarsamaj.org' },
    update: { passwordHash: hash, role: 'SUPER_ADMIN' },
    create: { email: 'admin@vankarsamaj.org', passwordHash: hash, role: 'SUPER_ADMIN', name: 'Super Admin', status: 'ACTIVE' }
  });
  
  await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: { passwordHash: hash, role: 'USER' },
    create: { email: 'test@example.com', passwordHash: hash, role: 'USER', name: 'Test User', status: 'ACTIVE' }
  });
  
  await prisma.user.upsert({
    where: { email: 'panjabiparvindar77@gmail.com' },
    update: { passwordHash: hash, role: 'USER' },
    create: { email: 'panjabiparvindar77@gmail.com', passwordHash: hash, role: 'USER', name: 'Parvindar', status: 'ACTIVE' }
  });
}
addPersistentUsers().then(() => console.log('Done')).catch(console.error).finally(() => prisma.$disconnect());
