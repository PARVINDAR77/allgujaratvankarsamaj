const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function run() {
  try {
    const updated = await prisma.user.updateMany({
      where: { 
        email: { 
          in: [
            'admin@vankarsamaj.org', 
            'admin@vankarsamaj.com', 
            'panjabiparvindar77@gmail.com'
          ] 
        } 
      },
      data: { 
        role: 'SUPER_ADMIN',
        status: 'ACTIVE'
      }
    });

    console.log(`Updated ${updated.count} admin user(s) to SUPER_ADMIN.`);
    
    const users = await prisma.user.findMany({
      where: { 
        email: { 
          in: [
            'admin@vankarsamaj.org', 
            'admin@vankarsamaj.com', 
            'panjabiparvindar77@gmail.com'
          ] 
        } 
      },
      select: { id: true, email: true, role: true, status: true }
    });
    console.log('Current Admin Users:', JSON.stringify(users, null, 2));
  } catch (err) {
    console.error('Error updating roles:', err);
  } finally {
    await prisma.$disconnect();
  }
}
run();
