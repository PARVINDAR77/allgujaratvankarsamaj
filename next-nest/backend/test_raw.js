const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  console.log(await prisma.$queryRaw`SELECT 1`);
}
main().finally(() => prisma.$disconnect());
