/**
 * Deterministic Synthetic Staging Database Seeder (CommonJS)
 * Requires ONLY production dependencies (@prisma/client, bcrypt).
 * Zero devDependencies required (no ts-node, no typescript compiler needed at runtime).
 *
 * Strict Fail-Closed Safety Guards:
 * 1. Hard stop if NODE_ENV !== 'staging'.
 * 2. Hard stop if DATABASE_URL does not target 'vankar_matrimony_staging' on loopback.
 * 3. Runtime database identity check (SELECT DATABASE() === 'vankar_matrimony_staging').
 * 4. Credentials file write failure is strictly fatal.
 * 5. Explicit mode 0600 enforcement and symlink rejection on credentials file.
 */

const { PrismaClient, Role, Status, Gender, MaritalStatus, ProfileStatus } = require('@prisma/client');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');

// --- SAFETY GUARD 1: Environment Assertion ---
if (process.env.NODE_ENV !== 'staging') {
  console.error('\x1b[31m[FATAL SAFETY VIOLATION] seed_staging.js can ONLY run when NODE_ENV=staging!\x1b[0m');
  console.error(`Current NODE_ENV: '${process.env.NODE_ENV}'`);
  process.exit(1);
}

// --- SAFETY GUARD 2: Database URL Target Allowlist ---
const dbUrlStr = process.env.DATABASE_URL || '';
if (!dbUrlStr) {
  console.error('\x1b[31m[FATAL SAFETY VIOLATION] DATABASE_URL is not set!\x1b[0m');
  process.exit(1);
}

let parsedDbUrl;
try {
  parsedDbUrl = new URL(dbUrlStr);
} catch (e) {
  console.error('\x1b[31m[FATAL SAFETY VIOLATION] Invalid DATABASE_URL format!\x1b[0m');
  process.exit(1);
}

const dbName = parsedDbUrl.pathname.replace(/^\//, '');
const dbHost = parsedDbUrl.hostname.toLowerCase();

if (dbName !== 'vankar_matrimony_staging') {
  console.error('\x1b[31m[FATAL SAFETY VIOLATION] Target database MUST be "vankar_matrimony_staging"!\x1b[0m');
  console.error(`Attempted database target: '${dbName}'`);
  process.exit(1);
}

if (!['127.0.0.1', 'localhost'].includes(dbHost)) {
  console.error('\x1b[31m[FATAL SAFETY VIOLATION] Database host MUST be loopback (127.0.0.1 or localhost)!\x1b[0m');
  console.error(`Attempted database host: '${dbHost}'`);
  process.exit(1);
}

const prisma = new PrismaClient();

async function seedStaging() {
  console.log('--- Staging Database Provisioning: Synthetic Seed Fixtures ---');

  // --- SAFETY GUARD 3: Runtime SQL Engine Identity Check ---
  const [dbResult] = await prisma.$queryRawUnsafe('SELECT DATABASE() as current_db, CURRENT_USER() as current_user');
  if (!dbResult || dbResult.current_db !== 'vankar_matrimony_staging') {
    console.error('\x1b[31m[FATAL SAFETY VIOLATION] Runtime SQL check failed: not connected to vankar_matrimony_staging!\x1b[0m');
    console.error(`Actual connected database: '${dbResult ? dbResult.current_db : 'unknown'}'`);
    process.exit(1);
  }
  console.log(`[VERIFIED] Connected to isolated staging database: ${dbResult.current_db} as ${dbResult.current_user}`);

  // Generate dynamic temporary credentials for this staging run
  const adminPass = process.env.STAGING_ADMIN_PASS || ('StgAdmin_' + crypto.randomBytes(12).toString('hex') + '!');
  const verifierPass = process.env.STAGING_VERIFIER_PASS || ('StgVerif_' + crypto.randomBytes(12).toString('hex') + '!');
  const contentAdminPass = process.env.STAGING_CONTENT_PASS || ('StgCont_' + crypto.randomBytes(12).toString('hex') + '!');
  const memberPass = process.env.STAGING_MEMBER_PASS || ('StgMemb_' + crypto.randomBytes(12).toString('hex') + '!');

  const adminPasswordHash = await bcrypt.hash(adminPass, 10);
  const verifierPasswordHash = await bcrypt.hash(verifierPass, 10);
  const contentAdminPasswordHash = await bcrypt.hash(contentAdminPass, 10);
  const memberPasswordHash = await bcrypt.hash(memberPass, 10);

  // --- SAFETY GUARD 4: Secure Credentials File Storage (FATAL on failure) ---
  const credsFile = process.env.STAGING_CREDENTIALS_FILE || '/home/u796269890/staging/.staging_test_credentials.json';
  const normalizedCredsPath = path.resolve(credsFile);
  const credsDir = path.dirname(normalizedCredsPath);

  // 4.1 Ensure parent directory exists and check its canonical path
  fs.mkdirSync(credsDir, { recursive: true, mode: 0o700 });
  const realCredsDir = fs.realpathSync(credsDir);

  // 4.2 Prohibit placement within any web-exposed directory tree
  if (realCredsDir.includes('public_html') || realCredsDir.includes('domains') ||
      normalizedCredsPath.includes('public_html') || normalizedCredsPath.includes('domains')) {
    console.error('\x1b[31m[FATAL SECURITY ERROR] Credentials directory/path cannot be within a web document root!\x1b[0m');
    console.error(`Attempted directory: '${realCredsDir}'`);
    process.exit(1);
  }

  // 4.3 Validate parent directory permissions and ownership (must not be group/world-writable)
  const dirStat = fs.statSync(realCredsDir);
  if ((dirStat.mode & 0o022) !== 0) {
    console.error('\x1b[31m[FATAL SECURITY ERROR] Credentials parent directory is group- or world-writable!\x1b[0m');
    process.exit(1);
  }
  if (process.getuid && dirStat.uid !== process.getuid()) {
    console.error('\x1b[31m[FATAL SECURITY ERROR] Credentials parent directory is not owned by current user!\x1b[0m');
    process.exit(1);
  }

  // 4.4 Reject symlinks on the destination file if it already exists
  if (fs.existsSync(normalizedCredsPath)) {
    const lstat = fs.lstatSync(normalizedCredsPath);
    if (lstat.isSymbolicLink()) {
      console.error('\x1b[31m[FATAL SECURITY ERROR] Existing credentials file is a symbolic link! Aborting.\x1b[0m');
      process.exit(1);
    }
  }

  // 4.5 Atomic, safe write via exclusive file descriptor / temporary file in same owner-controlled directory
  try {
    const credsData = {
      adminEmail: 'staging_admin@vankarsamaj.internal',
      adminPass,
      verifierEmail: 'staging_verifier@vankarsamaj.internal',
      verifierPass,
      contentEmail: 'staging_content@vankarsamaj.internal',
      contentAdminPass,
      senderEmail: 'staging_sender@vankarsamaj.internal',
      receiverEmail: 'staging_receiver@vankarsamaj.internal',
      unconnectedEmail: 'staging_unconnected@vankarsamaj.internal',
      memberPass,
      generatedAt: new Date().toISOString()
    };

    const tmpCredsPath = path.join(realCredsDir, `.staging_creds_${crypto.randomBytes(8).toString('hex')}.tmp`);
    fs.writeFileSync(tmpCredsPath, JSON.stringify(credsData, null, 2), { mode: 0o600, flag: 'w' });
    fs.chmodSync(tmpCredsPath, 0o600);

    // Atomically replace target
    fs.renameSync(tmpCredsPath, normalizedCredsPath);
    fs.chmodSync(normalizedCredsPath, 0o600);

    // Verify mode and ownership
    const finalStat = fs.statSync(normalizedCredsPath);
    const finalPerms = (finalStat.mode & 0o777);
    if (finalPerms !== 0o600) {
      throw new Error(`Permissions check failed on ${normalizedCredsPath}: expected 0600, got ${finalPerms.toString(8)}`);
    }
    if (process.getuid && finalStat.uid !== process.getuid()) {
      throw new Error(`Ownership check failed on ${normalizedCredsPath}: file not owned by current process UID`);
    }
    console.log(`[VERIFIED] Dynamic staging credentials stored at: ${normalizedCredsPath} (permissions: 0600, verified owner).`);
  } catch (err) {
    console.error('\x1b[31m[FATAL] Failed to securely write staging test credentials file:\x1b[0m', err.message);
    process.exit(1);
  }

  // 1. Super Admin
  const adminEmail = 'staging_admin@vankarsamaj.internal';
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

  // Clean any existing test interests between these accounts for idempotency
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

module.exports = { seedStaging };

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
