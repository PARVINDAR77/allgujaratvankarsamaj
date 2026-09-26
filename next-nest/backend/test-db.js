const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: 'desc' },
    take: 5
  });
  console.log(users.map(u => ({ id: u.id, phone: u.phone, email: u.email })));
}

main().catch(console.error).finally(() => prisma.$disconnect());
