const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkData() {
  const count = await prisma.samajService.count();
  console.log(`SamajService count: ${count}`);
  
  if (count > 0) {
    const services = await prisma.samajService.findMany();
    console.log(services);
  }
}

checkData().finally(() => prisma.$disconnect());
