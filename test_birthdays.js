const { PrismaClient } = require('./next-nest/backend/node_modules/@prisma/client');

async function main() {
  const prisma = new PrismaClient();
  try {
    const today = new Date();
    const currentMonth = today.getMonth() + 1;
    const currentDay = today.getDate();

    console.log("Fetching profiles...");
    const profiles = await prisma.matrimonialProfile.findMany({
      where: {
        status: "APPROVED",
      },
    });
    console.log(`Fetched ${profiles.length} profiles.`);

    const birthdayProfiles = profiles.filter((profile) => {
      if (!profile.dateOfBirth) {
        console.log(`Profile ${profile.id} has no dateOfBirth!`);
        return false;
      }
      const dob = new Date(profile.dateOfBirth);
      return (
        dob.getMonth() + 1 === currentMonth && dob.getDate() === currentDay
      );
    });
    console.log(`Found ${birthdayProfiles.length} birthdays.`);
  } catch (error) {
    console.error("Error executing query:");
    console.error(error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
