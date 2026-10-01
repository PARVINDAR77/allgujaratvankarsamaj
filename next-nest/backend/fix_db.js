const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function fix() {
  await prisma.homeButtonConfig.update({
    where: { buttonId: 1 },
    data: { route: '/advertisement?placement=HOME_BANNER' }
  });
  console.log('Fixed Route for Button 1');
}
fix().catch(console.error).finally(()=>prisma.$disconnect());
