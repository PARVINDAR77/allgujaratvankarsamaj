const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function run() {
  await prisma.user.update({
    where: { email: 'admin@vankarsamaj.org' },
    data: { role: 'ADMIN' }
  });

  await prisma.user.update({
    where: { email: 'panjabiparvindar77@gmail.com' },
    data: { role: 'SUPER_ADMIN' }
  });

  console.log('Roles updated successfully');
  await prisma.$disconnect();
}
run();
