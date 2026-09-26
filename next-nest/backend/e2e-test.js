async function runE2E() {
  try {
    const baseURL = 'http://localhost:3000/api/v1';

    const email = 'user' + Math.floor(1000 + Math.random() * 9000) + '@example.com';
    console.log('1. Registering new user...', email);
    const registerRes = await fetch(`${baseURL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: email,
        password: 'Password123'
      })
    });
    const registerData = await registerRes.json();
    console.log('User registered.');

    const loginRes = await fetch(`${baseURL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: email,
        password: 'Password123'
      })
    });
    const loginData = await loginRes.json();
    if (!loginRes.ok) throw new Error(JSON.stringify(loginData));
    const token = loginData.accessToken;
    console.log('User token acquired.');

    console.log('2. Creating profile...');
    const profileRes = await fetch(`${baseURL}/profiles`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({
        firstName: 'Ramesh',
        lastName: 'Vankar',
        dateOfBirth: '1995-05-15',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
        religion: 'Hinduism',
        caste: 'Hindu-Vankar',
        city: 'Ahmedabad',
        state: 'Gujarat',
        country: 'India',
        education: 'B.E.',
        occupation: 'Software Engineer'
      })
    });
    const profileData = await profileRes.json();
    if (!profileRes.ok) throw new Error(JSON.stringify(profileData));
    console.log('Profile created:', profileData.firstName);

    // 3. Admin login to approve
    console.log('3. Admin login...');
    const adminRes = await fetch(`${baseURL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'admin@vankarsamaj.org',
        password: 'Password123'
      })
    });
    const adminData = await adminRes.json();
    if (!adminRes.ok) throw new Error(JSON.stringify(adminData));
    const adminToken = adminData.accessToken;
    console.log('Admin token acquired.');

    console.log('4. Approving profile...');
    const approveRes = await fetch(`${baseURL}/admin/profiles/${profileData.id}/status`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${adminToken}` },
      body: JSON.stringify({ status: 'APPROVED' })
    });
    const approveData = await approveRes.json();
    if (!approveRes.ok) throw new Error(JSON.stringify(approveData));
    console.log('Profile approved:', approveData.status);

    console.log('5. Searching for profile...');
    const searchRes = await fetch(`${baseURL}/profiles`);
    let searchData = await searchRes.json();
    if (!searchRes.ok) throw new Error(JSON.stringify(searchData));
    
    if (searchData.data) searchData = searchData.data;
    
    console.log(`Found ${searchData.length} profiles.`);
    const found = searchData.find(p => p.id === profileData.id);
    if (found) {
      console.log('E2E TEST PASSED: Profile found in search results!');
    } else {
      console.log('E2E TEST FAILED: Profile not found in search results.');
    }

  } catch (err) {
    console.error('Test failed:', err.message);
  }
}

runE2E();
