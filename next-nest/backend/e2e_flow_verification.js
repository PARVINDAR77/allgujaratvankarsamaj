const fs = require('fs');

const BASE_URL = 'http://localhost:3000/api/v1';

async function apiCall(endpoint, method, body, token = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${BASE_URL}${endpoint}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`HTTP ${res.status}: ${errorText}`);
  }

  // Handle empty responses
  const text = await res.text();
  return text ? JSON.parse(text) : {};
}

async function runE2E() {
  console.log('--- STARTING PHASE 28 E2E VERIFICATION ---');

  // Randomize emails so we can run this multiple times without collision
  const timestamp = Date.now();
  const groomEmail = `groom_${timestamp}@example.com`;
  const brideEmail = `bride_${timestamp}@example.com`;
  const password = 'Password123!';

  let groomToken = '';
  let brideToken = '';
  let adminToken = '';

  try {
    console.log('\n[1/11] Registering User A (Groom)...');
    await apiCall('/auth/register', 'POST', { email: groomEmail, password });
    console.log('Groom registered.');

    console.log('\n[2/11] Registering User B (Bride)...');
    await apiCall('/auth/register', 'POST', { email: brideEmail, password });
    console.log('Bride registered.');

    console.log('\n[3/11] Logging in Groom and Bride...');
    const groomLogin = await apiCall('/auth/login', 'POST', { email: groomEmail, password });
    groomToken = groomLogin.accessToken;
    
    const brideLogin = await apiCall('/auth/login', 'POST', { email: brideEmail, password });
    brideToken = brideLogin.accessToken;
    console.log('Logins successful.');

    console.log('\n[4/11] Completing Groom Profile...');
    const groomProfileRes = await apiCall('/profiles', 'POST', {
      firstName: 'Rahul', lastName: 'Parmar', gender: 'MALE', dateOfBirth: '1995-05-10',
      maritalStatus: 'NEVER_MARRIED', religion: 'Hindu',
      caste: 'Vankar', education: 'B.Tech',
      occupation: 'Software Engineer',
      city: 'Ahmedabad', state: 'Gujarat',
      country: 'India', about: 'Good guy'
    }, groomToken);
    const groomProfileId = groomProfileRes.id;
    console.log(`Groom Profile Created: ${groomProfileId}`);

    console.log('\n[5/11] Completing Bride Profile...');
    const brideProfileRes = await apiCall('/profiles', 'POST', {
      firstName: 'Priya', lastName: 'Chavda', gender: 'FEMALE', dateOfBirth: '1997-08-20',
      maritalStatus: 'NEVER_MARRIED', religion: 'Hindu',
      caste: 'Vankar', education: 'M.Com',
      occupation: 'Banker',
      city: 'Surat', state: 'Gujarat',
      country: 'India', about: 'Good girl'
    }, brideToken);
    const brideProfileId = brideProfileRes.id;
    console.log(`Bride Profile Created: ${brideProfileId}`);

    console.log('\n[6/11] Submitting Verifications...');
    await apiCall('/verifications/submit', 'POST', { documentType: 'AADHAAR', documentUrl: 'http://example.com/aadhaar1.jpg' }, groomToken);
    await apiCall('/verifications/submit', 'POST', { documentType: 'AADHAAR', documentUrl: 'http://example.com/aadhaar2.jpg' }, brideToken);
    console.log('Verifications submitted.');

    console.log('\n[7/11] Admin Review & Approval...');
    let adminLogin = await apiCall('/auth/login', 'POST', { email: 'admin@vankarsamaj.com', password: 'password123' });
    if (!adminLogin.accessToken) {
       adminLogin = await apiCall('/auth/login', 'POST', { email: 'admin@vankarsamaj.com', password: 'Admin@123' });
    }
    adminToken = adminLogin.accessToken;
    
    const pendingVerifs = await apiCall('/admin/verifications', 'GET', null, adminToken);
    
    const groomVerif = pendingVerifs.find(v => v.profileId === groomProfileId);
    if(groomVerif) {
       await apiCall(`/admin/verifications/${groomVerif.id}/verify`, 'PATCH', { status: 'VERIFIED' }, adminToken);
    }
    const brideVerif = pendingVerifs.find(v => v.profileId === brideProfileId);
    if(brideVerif) {
       await apiCall(`/admin/verifications/${brideVerif.id}/verify`, 'PATCH', { status: 'VERIFIED' }, adminToken);
    }
    console.log('Admin approved verifications.');

    console.log('\n[8/11] Flutter Search (Groom searching for Bride)...');
    const searchRes = await apiCall('/profiles?gender=FEMALE&limit=10', 'GET', null, groomToken);
    const searchResults = searchRes.items;
    console.log(`Search returned ${searchResults.length} female profiles.`);
    
    const foundBride = searchResults.find(p => p.id === brideProfileId);
    if (!foundBride) {
      throw new Error("Groom could not find Bride in search results. Check approval/public eligibility status.");
    }
    console.log('Groom successfully found Bride in search.');

    console.log('\n[9/11] Open Profile...');
    const profileViewRes = await apiCall(`/profiles/${brideProfileId}`, 'GET', null, groomToken);
    console.log(`Groom loaded details for ${profileViewRes.firstName} ${profileViewRes.lastName}`);

    console.log('\n[10/11] Send Interest...');
    await apiCall('/interests/send', 'POST', { targetProfileId: brideProfileId }, groomToken);
    console.log('Groom sent interest to Bride.');

    console.log('\n[11/11] Recipient Accepts Mutual Interest...');
    const receivedInterests = await apiCall('/interests/received', 'GET', null, brideToken);
    const groomInterest = receivedInterests.find(i => i.senderProfileId === groomProfileId);
    
    if (!groomInterest) {
      throw new Error("Bride did not receive the interest from Groom.");
    }
    
    await apiCall(`/interests/${groomInterest.id}/accept`, 'PATCH', null, brideToken);
    console.log('Bride ACCEPTED the interest.');

    console.log('\n✅ Phase 28 E2E VERIFICATION COMPLETED SUCCESSFULLY!');
    
  } catch (error) {
    console.error('\n❌ E2E VERIFICATION FAILED:', error.message);
  }
}

runE2E();
