const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany();
  console.log('Existing users:');
  users.forEach(u => console.log(`- ${u.email} (Role: ${u.role})`));

  if (users.length === 0) {
    console.log('Creating a test user...');
    const hashedPassword = await bcrypt.hash('Password123', 10);
    const newUser = await prisma.user.create({
      data: {
        email: 'test@user.com',
        passwordHash: hashedPassword,
        role: 'USER',
        status: 'ACTIVE'
      }
    });
    console.log(`Created test user: test@user.com / Password123`);
  }
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());
