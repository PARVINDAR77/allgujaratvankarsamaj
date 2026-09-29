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

  const text = await res.text();
  const data = text ? JSON.parse(text) : {};
  return { status: res.status, data };
}

async function runSecurityTests() {
  console.log('--- STARTING PHASE 29 SECURITY VERIFICATION ---');

  const timestamp = Date.now();
  const userAEmail = `hackerA_${timestamp}@example.com`;
  const userBEmail = `victimB_${timestamp}@example.com`;
  const password = 'Password123!';

  let userAToken = '';
  let userBToken = '';
  let userAProfileId = '';
  let userBProfileId = '';

  try {
    console.log('\n[Setup] Registering Hacker A and Victim B...');
    await apiCall('/auth/register', 'POST', { email: userAEmail, password });
    await apiCall('/auth/register', 'POST', { email: userBEmail, password });

    const loginA = await apiCall('/auth/login', 'POST', { email: userAEmail, password });
    userAToken = loginA.data.accessToken;

    const loginB = await apiCall('/auth/login', 'POST', { email: userBEmail, password });
    userBToken = loginB.data.accessToken;

    const profileA = await apiCall('/profiles', 'POST', {
      firstName: 'Hacker', lastName: 'A', gender: 'MALE', dateOfBirth: '1990-01-01', maritalStatus: 'NEVER_MARRIED'
    }, userAToken);
    userAProfileId = profileA.data.id;

    const profileB = await apiCall('/profiles', 'POST', {
      firstName: 'Victim', lastName: 'B', gender: 'FEMALE', dateOfBirth: '1992-01-01', maritalStatus: 'NEVER_MARRIED'
    }, userBToken);
    userBProfileId = profileB.data.id;

    console.log('Setup complete.');
    let passed = 0;
    let failed = 0;

    function assertEq(name, actual, expected) {
      if (actual === expected) {
        console.log(`✅ [PASS] ${name} (Received ${actual})`);
        passed++;
      } else {
        console.error(`❌ [FAIL] ${name} (Expected ${expected}, got ${actual})`);
        failed++;
      }
    }

    console.log('\n--- 1. Authentication Testing ---');
    const authTest = await apiCall('/auth/me', 'GET');
    assertEq('Unauthenticated access blocked', authTest.status, 401);

    console.log('\n--- 2. Authorization (RBAC) Testing ---');
    const adminTest = await apiCall('/admin/verifications', 'GET', null, userAToken);
    assertEq('Standard user blocked from Admin API', adminTest.status, 403);

    console.log('\n--- 3. Ownership / Logic Testing ---');
    // Hacker tries to send interest to themselves
    const selfInterest = await apiCall('/interests/send', 'POST', { targetProfileId: userAProfileId }, userAToken);
    assertEq('Blocked sending interest to self', selfInterest.status, 400);

    // Victim B sends interest to Hacker A
    await apiCall('/interests/send', 'POST', { targetProfileId: userAProfileId }, userBToken);
    const hackerReceived = await apiCall('/interests/received', 'GET', null, userAToken);
    const interestId = hackerReceived.data[0].id;

    // Hacker A tries to DECLINE the interest using Victim B's token (Wait, B cannot decline an interest sent to A)
    const spoofDecline = await apiCall(`/interests/${interestId}/decline`, 'PATCH', null, userBToken);
    assertEq('Blocked Victim B from declining Hacker A\'s received interest', spoofDecline.status, 400);

    console.log('\n--- 4. Input Validation (Parameter Tampering) ---');
    // Hacker tries to bypass verification by submitting it directly in profile update payload
    const tamperUpdate = await apiCall('/profiles/me', 'PATCH', { isVerified: true }, userAToken);
    assertEq('Blocked injection of non-whitelisted property (isVerified)', tamperUpdate.status, 400);

    console.log(`\n=== SECURITY TEST RESULTS ===`);
    console.log(`Passed: ${passed}`);
    console.log(`Failed: ${failed}`);

    if (failed > 0) {
      process.exit(1);
    }
  } catch (err) {
    console.error('Fatal Test Error:', err);
    process.exit(1);
  }
}

runSecurityTests();
