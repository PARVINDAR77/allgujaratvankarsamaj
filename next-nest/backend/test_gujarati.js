const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // Insert a test user with Gujarati text
  const user = await prisma.user.create({
    data: {
      email: `test_${Date.now()}@gujarat.com`,
      passwordHash: 'fake',
      role: 'USER',
      status: 'ACTIVE',
    }
  });

  const profile = await prisma.matrimonialProfile.create({
    data: {
      userId: user.id,
      firstName: 'ગુજરાત',
      lastName: 'વણકર સમાજ',
      city: 'અમદાવાદ',
      state: 'ગુજરાત',
      country: 'India',
      about: '૩૫ ગામ પરગણું, ઈડર',
      gender: 'MALE',
      dateOfBirth: new Date('1990-01-01'),
      maritalStatus: 'NEVER_MARRIED',
      religion: 'Hindu',
      caste: 'Vankar',
      education: 'B.A.',
      occupation: 'Job',
      status: 'APPROVED'
    }
  });

  // Read it back
  const fetched = await prisma.matrimonialProfile.findUnique({
    where: { id: profile.id }
  });

  console.log('Inserted:', profile.firstName, profile.lastName, profile.city, profile.about);
  console.log('Fetched:', fetched.firstName, fetched.lastName, fetched.city, fetched.about);

  if (fetched.firstName === 'ગુજરાત' && fetched.lastName === 'વણકર સમાજ' && fetched.city === 'અમદાવાદ' && fetched.about === '૩૫ ગામ પરગણું, ઈડર') {
    console.log('GUJARATI_TEST_PASS');
  } else {
    console.log('GUJARATI_TEST_FAIL');
  }

  // Delete it
  await prisma.matrimonialProfile.delete({ where: { id: profile.id } });
  await prisma.user.delete({ where: { id: user.id } });
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
