import { PrismaClient, Role, Status, Gender, MaritalStatus, ProfileStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

export async function seedStaging() {
  console.log('--- Staging Database Provisioning: Synthetic Seed Fixtures ---');

  // Staging credentials - used solely in isolated staging DB for end-to-end smoke tests
  const adminPasswordHash = await bcrypt.hash('StagingAdminPassword2026!', 10);
  const verifierPasswordHash = await bcrypt.hash('StagingVerifierPassword2026!', 10);
  const contentAdminPasswordHash = await bcrypt.hash('StagingContentPassword2026!', 10);
  const memberPasswordHash = await bcrypt.hash('MemberPassword123!', 10);

  // 1. Super Admin
  const adminEmail = 'staging_admin@vankarsamaj.internal';
  console.log(`Seeding Super Admin: ${adminEmail}`);
  await prisma.user.upsert({
    where: { email: adminEmail },
    update: { passwordHash: adminPasswordHash, role: Role.SUPER_ADMIN, status: Status.ACTIVE },
    create: {
      email: adminEmail,
      phone: '9900000001',
      name: 'Staging Super Admin',
      passwordHash: adminPasswordHash,
      role: Role.SUPER_ADMIN,
      status: Status.ACTIVE,
    },
  });

  // 2. Verification Admin
  const verifierEmail = 'staging_verifier@vankarsamaj.internal';
  console.log(`Seeding Verification Admin: ${verifierEmail}`);
  await prisma.user.upsert({
    where: { email: verifierEmail },
    update: { passwordHash: verifierPasswordHash, role: Role.VERIFICATION_ADMIN, status: Status.ACTIVE },
    create: {
      email: verifierEmail,
      phone: '9900000002',
      name: 'Staging Verification Admin',
      passwordHash: verifierPasswordHash,
      role: Role.VERIFICATION_ADMIN,
      status: Status.ACTIVE,
    },
  });

  // 3. Content Admin
  const contentEmail = 'staging_content@vankarsamaj.internal';
  console.log(`Seeding Content Admin: ${contentEmail}`);
  await prisma.user.upsert({
    where: { email: contentEmail },
    update: { passwordHash: contentAdminPasswordHash, role: Role.CONTENT_ADMIN, status: Status.ACTIVE },
    create: {
      email: contentEmail,
      phone: '9900000003',
      name: 'Staging Content Admin',
      passwordHash: contentAdminPasswordHash,
      role: Role.CONTENT_ADMIN,
      status: Status.ACTIVE,
    },
  });

  // 4. Member A (Sender)
  const senderEmail = 'staging_sender@vankarsamaj.internal';
  console.log(`Seeding Member A (Sender): ${senderEmail}`);
  const senderUser = await prisma.user.upsert({
    where: { email: senderEmail },
    update: { passwordHash: memberPasswordHash, status: Status.ACTIVE },
    create: {
      email: senderEmail,
      phone: '9876500001',
      name: 'Aarav Vankar',
      gender: Gender.MALE,
      passwordHash: memberPasswordHash,
      role: Role.USER,
      status: Status.ACTIVE,
    },
  });

  await prisma.matrimonialProfile.upsert({
    where: { userId: senderUser.id },
    update: {
      firstName: 'Aarav',
      lastName: 'Vankar',
      gender: Gender.MALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: senderEmail,
      fatherContact: '9876500099',
    },
    create: {
      userId: senderUser.id,
      firstName: 'Aarav',
      lastName: 'Vankar',
      dateOfBirth: new Date(1996, 4, 15),
      gender: Gender.MALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      religion: 'Hindu',
      caste: 'Vankar',
      city: 'Ahmedabad',
      state: 'Gujarat',
      country: 'India',
      education: 'B.Tech IT',
      occupation: 'Software Engineer',
      about: 'Staging test profile for sender candidate.',
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: senderEmail,
      fatherContact: '9876500099',
    },
  });

  // 5. Member B (Receiver / Target with strict privacy)
  const receiverEmail = 'staging_receiver@vankarsamaj.internal';
  console.log(`Seeding Member B (Receiver): ${receiverEmail}`);
  const receiverUser = await prisma.user.upsert({
    where: { email: receiverEmail },
    update: { passwordHash: memberPasswordHash, status: Status.ACTIVE },
    create: {
      email: receiverEmail,
      phone: '9876500002',
      name: 'Bhavana Solanki',
      gender: Gender.FEMALE,
      passwordHash: memberPasswordHash,
      role: Role.USER,
      status: Status.ACTIVE,
    },
  });

  await prisma.matrimonialProfile.upsert({
    where: { userId: receiverUser.id },
    update: {
      firstName: 'Bhavana',
      lastName: 'Solanki',
      gender: Gender.FEMALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: receiverEmail,
      fatherContact: '9876500088',
      guardianContact: '9876500087',
      addressLine: '102 Royal Residency, Paldi',
      pincode: '380007',
      privacySettings: JSON.stringify({
        mobile: 'માત્ર મને',
        email: 'માત્ર મને',
        address: 'પરિવારજનો',
        guardian: 'પરિવારજનો',
      }),
    },
    create: {
      userId: receiverUser.id,
      firstName: 'Bhavana',
      lastName: 'Solanki',
      dateOfBirth: new Date(1998, 8, 20),
      gender: Gender.FEMALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      religion: 'Hindu',
      caste: 'Vankar',
      city: 'Gandhinagar',
      state: 'Gujarat',
      country: 'India',
      education: 'M.Sc Chemistry',
      occupation: 'Research Associate',
      about: 'Staging test profile for receiver candidate with restricted privacy.',
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: receiverEmail,
      fatherContact: '9876500088',
      guardianContact: '9876500087',
      addressLine: '102 Royal Residency, Paldi',
      pincode: '380007',
      privacySettings: JSON.stringify({
        mobile: 'માત્ર મને',
        email: 'માત્ર મને',
        address: 'પરિવારજનો',
        guardian: 'પરિવારજનો',
      }),
    },
  });

  // 6. Member C (Unconnected)
  const unconnectedEmail = 'staging_unconnected@vankarsamaj.internal';
  console.log(`Seeding Member C (Unconnected): ${unconnectedEmail}`);
  const unconnectedUser = await prisma.user.upsert({
    where: { email: unconnectedEmail },
    update: { passwordHash: memberPasswordHash, status: Status.ACTIVE },
    create: {
      email: unconnectedEmail,
      phone: '9876500003',
      name: 'Charmy Parmar',
      gender: Gender.FEMALE,
      passwordHash: memberPasswordHash,
      role: Role.USER,
      status: Status.ACTIVE,
    },
  });

  await prisma.matrimonialProfile.upsert({
    where: { userId: unconnectedUser.id },
    update: {
      firstName: 'Charmy',
      lastName: 'Parmar',
      gender: Gender.FEMALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: unconnectedEmail,
      fatherContact: '9876500077',
      privacySettings: JSON.stringify({
        mobile: 'માત્ર મને',
        email: 'માત્ર મને',
        address: 'પરિવારજનો',
        guardian: 'પરિવારજનો',
      }),
    },
    create: {
      userId: unconnectedUser.id,
      firstName: 'Charmy',
      lastName: 'Parmar',
      dateOfBirth: new Date(1999, 1, 10),
      gender: Gender.FEMALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      religion: 'Hindu',
      caste: 'Vankar',
      city: 'Vadodara',
      state: 'Gujarat',
      country: 'India',
      education: 'MBA Marketing',
      occupation: 'Executive',
      about: 'Staging test profile for unconnected candidate.',
      status: ProfileStatus.APPROVED,
      isVerified: true,
      contactEmail: unconnectedEmail,
      fatherContact: '9876500077',
      privacySettings: JSON.stringify({
        mobile: 'માત્ર મને',
        email: 'માત્ર મને',
        address: 'પરિવારજનો',
        guardian: 'પરિવારજનો',
      }),
    },
  });

  // Clean any existing staging test interests between these accounts so runs start clean
  const senderProf = await prisma.matrimonialProfile.findUnique({ where: { userId: senderUser.id } });
  const receiverProf = await prisma.matrimonialProfile.findUnique({ where: { userId: receiverUser.id } });
  if (senderProf && receiverProf) {
    await prisma.matchInterest.deleteMany({
      where: {
        OR: [
          { senderProfileId: senderProf.id, receiverProfileId: receiverProf.id },
          { senderProfileId: receiverProf.id, receiverProfileId: senderProf.id },
        ],
      },
    });
  }

  console.log('--- Staging Synthetic Seed Completed Successfully ---');
}

if (require.main === module) {
  seedStaging()
    .catch((err) => {
      console.error('Staging seed error:', err);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}
