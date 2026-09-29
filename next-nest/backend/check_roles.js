const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function run() {
  const admin = await prisma.user.findUnique({ where: { email: 'admin@vankarsamaj.org' } });
  console.log('Admin:', admin);

  // Check super admin
  const superAdmin = await prisma.user.findUnique({ where: { email: 'panjabiparvindar77@gmail.com' } });
  console.log('Super Admin:', superAdmin);
  await prisma.$disconnect();
}
run();
