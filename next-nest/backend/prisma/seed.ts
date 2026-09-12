import { PrismaClient, Gender, MaritalStatus, ProfileStatus } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

const maleFirstNames = [
  'Ramesh', 'Suresh', 'Jignesh', 'Mahesh', 'Bhavesh', 'Pankaj', 'Jayesh', 'Kiran', 'Nitin', 'Vijay',
  'Pravin', 'Dinesh', 'Ketan', 'Alpesh', 'Rajesh', 'Hitesh', 'Kamlesh', 'Chetan', 'Dipak', 'Vishal',
  'Amit', 'Hardik', 'Bhaveshkumar', 'Sanjay', 'Girish', 'Ashok', 'Paresh', 'Gopal', 'Mukesh', 'Harish',
  'Mehul', 'Manish', 'Nilesh', 'Tushar', 'Chirag', 'Sachin', 'Anil', 'Bharat', 'Kunal', 'Pratik',
  'Rakesh', 'Sunil', 'Yogesh', 'Haresh', 'Gautam', 'Jiten', 'Narendra', 'Vinod', 'Sandip', 'Mayur'
];

const femaleFirstNames = [
  'Pooja', 'Hiral', 'Neeta', 'Kavita', 'Riddhi', 'Bhavana', 'Daxaben', 'Kinjal', 'Nisha', 'Sejal',
  'Jalpa', 'Meghaben', 'Komal', 'Purvi', 'Swati', 'Priti', 'Payal', 'Sheetal', 'Sonam', 'Dipali',
  'Arti', 'Geetaben', 'Rekhaben', 'Minakshi', 'Sonal', 'Varsha', 'Krutika', 'Dharaben', 'Hetashree', 'Twinkle',
  'Urvashi', 'Shraddha', 'Bhoomi', 'Tejal', 'Jyotiben', 'Dhruti', 'Kavita', 'Janki', 'Vaishali', 'Mittal',
  'Monika', 'Pinky', 'Chhaya', 'Shilpa', 'Asha', 'Falguni', 'Roshni', 'Priyanka', 'Heena', 'Ankita'
];

const lastNames = [
  'Vankar', 'Parmar', 'Solanki', 'Chauhan', 'Rathod', 'Makwana', 'Jadav', 'Vaghela', 'Gohel', 'Kapadiya',
  'Chavda', 'Dabhi', 'Shah', 'Patel', 'Mahyavanshi', 'Chitroda', 'Rohit', 'Purabiya', 'Maru', 'Vanol'
];

const cities = [
  'Ahmedabad', 'Vadodara', 'Surat', 'Rajkot', 'Gandhinagar', 'Himatnagar', 'Idar', 'Anand', 'Nadiad', 'Mehsana',
  'Palanpur', 'Bhavnagar', 'Jamnagar', 'Junagadh', 'Bharuch', 'Navsari', 'Valsad', 'Godhra', 'Patan', 'Modasa'
];

const educations = [
  'B.Tech Computer Engineering', 'BE Mechanical', 'M.Sc Information Technology', 'MBA Finance', 'MBBS Doctor',
  'B.Ed Teacher', 'B.Com Accounting', 'M.Com', 'BCA / MCA', 'Diploma Electrical', 'B.Pharm', 'LL.B Lawyer',
  'M.A. Gujarati', 'B.Sc Chemistry', 'Chartered Accountant (CA)', 'Civil Engineer', 'Ph.D. Scholar', 'H.S.C (12th Passed)'
];

const occupations = [
  'Software Engineer', 'GPSC Class-2 Officer', 'High School Teacher', 'Bank Manager', 'Government Servant (Revenue)',
  'Assistant Engineer (GETCO)', 'Private Sector Employee', 'Business Owner (Textile)', 'Pharmacist', 'Police Sub-Inspector',
  'Accountant', 'Graphic Designer', 'Data Analyst', 'Architect', 'Quality Control Executive', 'Digital Specialist'
];

const religions = ['Hindu', 'Buddhist', 'Jain'];
const castes = ['Vankar', 'Vankar Samaj', 'Weaver Community'];

async function main() {
  console.log('Seed process starting: Creating 100 fake Vankar Samaj Matrimonial Profiles...');

  // Ensure default demo user exists for foreign key setup
  let defaultUser = await prisma.user.findFirst();
  if (!defaultUser) {
    defaultUser = await prisma.user.create({
      data: {
        email: 'panjabiparvindar77@gmail.com',
        passwordHash: '$2b$10$e8.Z/yD1P4x.4z8y1z5.7O2qG5YpW.6j1.5e', // Parvindar@123
        role: 'USER',
        status: 'ACTIVE',
      },
    });
  }

  for (let i = 1; i <= 100; i++) {
    const isMale = i % 2 !== 0;
    const gender = isMale ? Gender.MALE : Gender.FEMALE;
    const firstName = isMale
      ? maleFirstNames[Math.floor(Math.random() * maleFirstNames.length)]
      : femaleFirstNames[Math.floor(Math.random() * femaleFirstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const city = cities[Math.floor(Math.random() * cities.length)];
    const education = educations[Math.floor(Math.random() * educations.length)];
    const occupation = occupations[Math.floor(Math.random() * occupations.length)];
    const religion = religions[Math.floor(Math.random() * religions.length)];
    const caste = castes[Math.floor(Math.random() * castes.length)];

    // Birth year between 1988 and 2005 (ages 21 to 38)
    const birthYear = 1988 + Math.floor(Math.random() * 17);
    const birthMonth = Math.floor(Math.random() * 12);
    const birthDay = 1 + Math.floor(Math.random() * 28);
    const dateOfBirth = new Date(birthYear, birthMonth, birthDay);

    // Create unique shadow user account for each fake profile
    const fakeEmail = `candidate${i}_${Date.now()}@vankarsamaj.org`;
    const user = await prisma.user.create({
      data: {
        email: fakeEmail,
        passwordHash: '$2b$10$e8.Z/yD1P4x.4z8y1z5.7O2qG5YpW.6j1.5e',
        role: 'USER',
        status: 'ACTIVE',
      },
    });

    await prisma.matrimonialProfile.create({
      data: {
        userId: user.id,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        maritalStatus: MaritalStatus.NEVER_MARRIED,
        religion,
        caste,
        city,
        state: 'Gujarat',
        country: 'India',
        education,
        occupation,
        about: `Sincere and family-oriented ${isMale ? 'groom' : 'bride'} looking for a suitable life partner within the Vankar Samaj community.`,
        status: ProfileStatus.APPROVED,
        isVerified: i % 3 === 0,
        isFeatured: i % 5 === 0,
      },
    });
  }

  console.log('Successfully created 100 fake profiles in database!');
}

main()
  .catch((e) => {
    console.error('Error seeding profiles:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
