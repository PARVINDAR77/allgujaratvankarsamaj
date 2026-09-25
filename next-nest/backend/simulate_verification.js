const http = require('http');

function request(path, options = {}) {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: '127.0.0.1',
      port: 3000,
      path,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      }
    }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, data: parsed, headers: res.headers });
        } catch(e) {
          resolve({ status: res.statusCode, data, headers: res.headers });
        }
      });
    });

    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- Phase 22 Verification E2E Tests ---');
  try {
    // 1. Create a mock user + profile
    const rand = Date.now();
    let res = await request('/api/v1/auth/register', {
      method: 'POST',
      body: { email: `verify_test_${rand}@example.com`, password: 'password123' }
    });
    
    if (res.status !== 201) {
      console.log('Failed to register mock user:', res.status, res.data);
      return;
    }
    
    // Login to get token
    res = await request('/api/v1/auth/login', {
      method: 'POST',
      body: { email: `verify_test_${rand}@example.com`, password: 'password123' }
    });
    
    const userToken = res.data.accessToken;
    
    res = await request('/api/v1/profiles', {
      method: 'POST',
      headers: { Authorization: `Bearer ${userToken}` },
      body: {
        firstName: 'Verify',
        lastName: 'Test',
        dateOfBirth: '1995-01-01T00:00:00Z',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
        about: 'Testing verification'
      }
    });
    console.log('[User] Create Profile ->', res.status, res.data);
    
    // 2. Submit Verification
    res = await request('/api/v1/verifications/submit', {
      method: 'POST',
      headers: { Authorization: `Bearer ${userToken}` },
      body: {
        documentType: 'Aadhaar Card',
        documentUrl: 'https://example.com/aadhaar.pdf'
      }
    });
    console.log('[User] Submit Verification ->', res.status);
    
    if (res.status !== 201) return;

    // 3. Admin Login
    res = await request('/api/v1/auth/login', {
      method: 'POST',
      body: { email: 'admin@vankarsamaj.com', password: 'password123' }
    });
    
    const setCookie = res.headers['set-cookie'] ? res.headers['set-cookie'][0] : '';
    console.log('[Admin] Login ->', res.status, setCookie ? 'Got Cookie' : 'No Cookie');
    
    // 4. Admin Get Verifications
    res = await request('/api/v1/admin/verifications', {
      method: 'GET',
      headers: { Cookie: setCookie }
    });
    console.log('[Admin] Get Verifications ->', res.status);
    
    if (res.status !== 200 || !Array.isArray(res.data) || res.data.length === 0) {
      console.log('No verifications found for admin', res.data);
      return;
    }
    
    const verificationId = res.data[0].id;
    const profileId = res.data[0].profileId;
    console.log(`Found Verification ID: ${verificationId} (Profile: ${profileId})`);

    // 5. Admin Approve Verification
    res = await request(`/api/v1/admin/verifications/${verificationId}/verify`, {
      method: 'PATCH',
      headers: { Cookie: setCookie },
      body: { status: 'VERIFIED' }
    });
    console.log('[Admin] Approve Verification ->', res.status);

    // Verify Profile state
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    let p = await prisma.matrimonialProfile.findUnique({ where: { id: profileId } });
    console.log(`Profile isVerified = ${p.isVerified} (Expected: true)`);
    
    // Check Audit Log
    let logs = await prisma.adminAuditLog.findMany({ where: { entityId: verificationId } });
    console.log(`Audit Logs count = ${logs.length} (Expected: > 0)`);
    
    // 6. Test Rejection flow
    // User submits another verification
    res = await request('/api/v1/verifications/submit', {
      method: 'POST',
      headers: { Authorization: `Bearer ${userToken}` },
      body: {
        documentType: 'Passport',
        documentUrl: 'https://example.com/passport.pdf'
      }
    });
    console.log('[User] Submit 2nd Verification ->', res.status);
    
    res = await request('/api/v1/admin/verifications', {
      method: 'GET',
      headers: { Cookie: setCookie }
    });
    
    const verificationId2 = res.data.find(v => v.documentType === 'Passport').id;
    
    res = await request(`/api/v1/admin/verifications/${verificationId2}/verify`, {
      method: 'PATCH',
      headers: { Cookie: setCookie },
      body: { status: 'REJECTED', rejectionReason: 'Blurry document' }
    });
    console.log('[Admin] Reject Verification ->', res.status);
    
    let v2 = await prisma.verificationRequest.findUnique({ where: { id: verificationId2 } });
    console.log(`Verification Status = ${v2.status}, Reason = ${v2.rejectionReason} (Expected: REJECTED, Blurry document)`);

    // Auth tests
    res = await request(`/api/v1/admin/verifications`, { method: 'GET' });
    console.log(`[Test] Unauthenticated -> ${res.status} (Expected: 401)`);
    
    res = await request(`/api/v1/admin/verifications/${verificationId}/verify`, {
      method: 'PATCH', headers: { Cookie: setCookie }, body: { status: 'INVALID_STATUS' }
    });
    console.log(`[Test] Invalid Status -> ${res.status} (Expected: 400)`);
    
  } catch (err) {
    console.error('Error during execution:', err);
  }
}

runTests();
