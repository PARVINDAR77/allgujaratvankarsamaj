const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  console.log('Users:', await prisma.user.count());
  console.log('Profiles:', await prisma.matrimonialProfile.count());
  console.log('Samaj Services:', await prisma.samajService.count());
  console.log('Parganas:', await prisma.pargana.count());
  console.log('States:', await prisma.state.count());
  console.log('Districts:', await prisma.district.count());
  console.log('Talukas:', await prisma.taluka.count());
  console.log('Villages:', await prisma.village.count());
}
main().finally(() => prisma.$disconnect());
