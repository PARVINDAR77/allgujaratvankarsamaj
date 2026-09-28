const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcrypt');

async function main() {
  const hash = await bcrypt.hash('password123', 10);
  await prisma.user.create({
    data: {
      email: 'panjabiparvindar77@gmail.com',
      passwordHash: hash,
      role: 'SUPER_ADMIN',
      name: 'Super Admin',
      status: 'ACTIVE'
    }
  });
  await prisma.user.create({
    data: {
      email: 'test@example.com',
      passwordHash: hash,
      role: 'USER',
      name: 'Test User',
      status: 'ACTIVE'
    }
  });
  console.log('Users created');
}

main().catch(console.error).finally(() => prisma.$disconnect());
