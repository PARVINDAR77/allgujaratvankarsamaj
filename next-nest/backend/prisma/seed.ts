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

  console.log('Seeding Samaj Services categories...');
  const samajServicesData = [
    {
      title: 'ઘર બાંધકામ અને સિવિલ વર્ક (Construction & Mason)',
      category: 'Home & Daily Life Services',
      icon: '🏠',
      contactPhone: '+91 98790 12345',
      contactPerson: 'રાજ મિસ્ત્રી રમેશભાઈ વણકર',
      description: 'ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), આરસીસી અને પ્લાસ્ટર કામકાજ સિંગલ ક્લિકથી.',
      isActive: true,
    },
    {
      title: 'પ્લમ્બિંગ અને ઇલેક્ટ્રિશિયન સર્વિસ (Plumber & Electrician)',
      category: 'Home & Daily Life Services',
      icon: '🔧',
      contactPhone: '+91 98250 67890',
      contactPerson: 'મહેશકુમાર પરમાર',
      description: 'ઇમરજન્સી વાયરિંગ, પ્લમ્બિંગ ફિટિંગ, ગીઝર અને મોટર સુધારણા સેવાઓ.',
      isActive: true,
    },
    {
      title: 'કલરકામ, પેઇન્ટિંગ અને એસી/ફ્રિજ રીપેર',
      category: 'Home & Daily Life Services',
      icon: '🎨',
      contactPhone: '+91 97123 45678',
      contactPerson: 'હસમુખભાઈ ચૌહાણ (Painter)',
      description: 'ઘર/ઓફિસ કલરકામ, વુડન પોલિશ, એસી સર્વિસિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર.',
      isActive: true,
    },
    {
      title: 'સુથારીકામ, એલ્યુમિનિયમ અને ગ્લાસ વર્ક (Carpenter)',
      category: 'Home & Daily Life Services',
      icon: '🪚',
      contactPhone: '+91 99099 88776',
      contactPerson: 'જીગ્નેશભાઈ સોલંકી',
      description: 'ફર્નિચર બનાવટ, દરવાજા ફિટિંગ, એલ્યુમિનિયમ સેક્શન અને ગ્લાસ વિન્ડો વુડવર્ક.',
      isActive: true,
    },
    {
      title: 'ગાડી બુકિંગ અને ટેક્સી સર્વિસ (Car Rental & Cab)',
      category: 'Vehicle & Transport',
      icon: '🚗',
      contactPhone: '+91 98980 11223',
      contactPerson: 'અશ્વિનભાઈ વાઘેલા (Taxi)',
      description: 'લગ્ન પ્રસંગ, પ્રવાસ કે ઇમરજન્સી માટે કાર રેન્ટલ, ટેક્સી અને ડ્રાઇવર બુકિંગ.',
      isActive: true,
    },
    {
      title: 'ઓટો/ગેરેજ, પંચર અને બેટરી સર્વિસ (Garage & Puncture)',
      category: 'Vehicle & Transport',
      icon: '🛞',
      contactPhone: '+91 98765 43210',
      contactPerson: 'કિરણભાઈ રોહિત (Garage)',
      description: 'ટુ-વીલર/ફોર-વીલર ગેરેજ, ટાયર પંચર, ઓન-રોડ આસિસ્ટન્સ અને કાર બેટરી.',
      isActive: true,
    },
    {
      title: 'કોમ્પ્યુટર/મોબાઇલ રીપેર અને પ્રિન્ટર સર્વિસ',
      category: 'Computer & Digital Services',
      icon: '💻',
      contactPhone: '+91 94270 99887',
      contactPerson: 'દિનેશભાઈ ચૌહાણ (Hardware)',
      description: 'લેપટોપ, કોમ્પ્યુટર સુધારણા, સ્માર્ટફોન ડિસ્પ્લે અને પ્રિન્ટર કાર્ટ્રેજ રીફિલિંગ.',
      isActive: true,
    },
    {
      title: 'વેબસાઇટ, મોબાઇલ એપ અને ગ્રાફિક ડિઝાઇનિંગ',
      category: 'Computer & Digital Services',
      icon: '🌐',
      contactPhone: '+91 99789 44556',
      contactPerson: 'અલ્પેશ પરમાર (IT Dev)',
      description: 'સમાજ ઉદ્યોગો માટે વેબસાઇટ ડેવલપમેન્ટ, બિઝનેસ એપ અને સોશિયલ મીડિયા ડિઝાઇન.',
      isActive: true,
    },
    {
      title: 'ટ્યુશન ક્લાસીસ અને સ્પર્ધાત્મક પરીક્ષા કોચિંગ',
      category: 'Education Services',
      icon: '📚',
      contactPhone: '+91 98989 98989',
      contactPerson: 'પ્રો. સંજયભાઈ વણકર',
      description: 'ધો. ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT/SSC પરીક્ષા માર્ગદર્શન અને પુસ્તક સહાય.',
      isActive: true,
    },
    {
      title: 'સમાજ જોબ પ્લેસમેન્ટ અને રિઝ્યુમ બિલ્ડર',
      category: 'Job & Business Services',
      icon: '💼',
      contactPhone: '+91 97111 22334',
      contactPerson: 'મનીષભાઈ ચૌહાણ (HR)',
      description: 'પ્રાઇવેટ અને સ્કિલ્ડ જોબ માહિતી, સીવી બનાવવા અને ઇન્ટરવ્યુ તૈયારી.',
      isActive: true,
    },
    {
      title: 'વકીલ સલાહ, દસ્તાવેજ અને પ્રોપર્ટી ગાઇડન્સ (Advocate)',
      category: 'Legal & Financial Services',
      icon: '⚖️',
      contactPhone: '+91 98251 44556',
      contactPerson: 'એડવોકેટ હસમુખ ચૌહાણ',
      description: 'કાનૂની સલાહ, જમીન-મિલકત દસ્તાવેજ લેખન, સોગંદનામા અને રેવન્યુ કેસ.',
      isActive: true,
    },
    {
      title: 'હોસ્પિટલ, ડૉક્ટર અને ડેન્ટલ કેર (Health & Doctor)',
      category: 'Health & Emergency',
      icon: '🏥',
      contactPhone: '+91 98791 66778',
      contactPerson: 'ડૉ. મહેશ પરમાર (MD)',
      description: 'સમાજ ડૉક્ટર્સ પેનલ, આંખના ડૉક્ટર, દાંતના ડૉક્ટર અને મફત આરોગ્ય કેમ્પ.',
      isActive: true,
    },
    {
      title: 'એમ્બ્યુલન્સ અને બ્લડ ડોનેશન ડિરેક્ટરી (Ambulance & Blood)',
      category: 'Health & Emergency',
      icon: '🩸',
      contactPhone: '+91 98252 77889',
      contactPerson: 'રક્તદાતા ગ્રુપ કંટ્રોલ',
      description: '૨૪x૭ ઇમરજન્સી એમ્બ્યુલન્સ, બ્લડ ડોનર નેટવર્ક અને લેબોરેટરી રિપોર્ટ સહાય.',
      isActive: true,
    },
    {
      title: 'કરિયાણું, કપડાં, ફર્નિચર અને જ્વેલર્સ શોપ',
      category: 'Business & Local Shops',
      icon: '🏪',
      contactPhone: '+91 99781 88990',
      contactPerson: 'વણકર ટ્રેડર્સ ગ્રુપ',
      description: 'સમાજના વેપારીઓનું હોલસેલ ગ્રોસરી, રેડીમેડ ગારમેન્ટ્સ, શૂઝ અને જ્વેલરી શોપિંગ.',
      isActive: true,
    },
    {
      title: 'વેલ્ડિંગ, મશીનરી અને ટેકનિશિયન વર્ક (Technicians)',
      category: 'Skilled Professionals',
      icon: '🧑🔧',
      contactPhone: '+91 98792 99001',
      contactPerson: 'પ્રકાશભાઈ વાઘેલા',
      description: 'ગ્રીલ/ગેટ વેલ્ડિંગ વર્ક, ટીવી ટેકનિશિયન, સીસીટીવી કેમેરા ફિટિંગ અને મશીનરી વર્ક.',
      isActive: true,
    },
  ];

  for (const s of samajServicesData) {
    await prisma.samajService.create({
      data: {
        ...s,
        slug: s.title.toLowerCase().replace(/ /g, '-'),
      },
    });
  }

  console.log('Successfully seeded all Samaj Services categories into database!');
}

main()
  .catch((e) => {
    console.error('Error seeding profiles:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
