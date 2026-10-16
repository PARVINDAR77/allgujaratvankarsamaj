const https = require('https');

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      let body = '';
      res.on('data', d => body += d);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(body), raw: body });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

(async () => {
  const host = process.env.TEST_API_HOST || '127.0.0.1';
  const port = process.env.TEST_API_PORT || 3000;
  if (host.includes('allgujaratvankarsamaj.com') || host.includes('217.21.94.138')) {
    console.error('SECURITY VIOLATION: Execution against production domain is prohibited.');
    process.exit(1);
  }

  // 1. Login with safe test fixture
  const loginData = JSON.stringify({
    email: process.env.TEST_USER_EMAIL || 'test-user@example.test',
    password: process.env.TEST_USER_PASSWORD || 'TestPassword123!'
  });
  const loginRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/auth/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginData)
    }
  }, loginData);

  const token = loginRes.body?.accessToken;
  console.log('Login status:', loginRes.status, 'Has token:', !!token);

  if (!token) return;

  const authHeaders = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };

  // 2. Test GET /shortlists/ids
  const idsRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/shortlists/ids',
    method: 'GET',
    headers: authHeaders
  });
  console.log('GET /api/v1/shortlists/ids:', idsRes.status, idsRes.body || idsRes.raw);

  // 3. Test GET /shortlists
  const listRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/shortlists',
    method: 'GET',
    headers: authHeaders
  });
  console.log('GET /api/v1/shortlists:', listRes.status, listRes.body || listRes.raw);

  // 4. Get a profile to test toggle
  const profilesRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/profiles?limit=2',
    method: 'GET',
    headers: authHeaders
  });
  console.log('GET /api/v1/profiles status:', profilesRes.status);
  const profiles = profilesRes.body?.data || profilesRes.body;
  const sampleProfile = Array.isArray(profiles) ? profiles[0] : null;
  console.log('Sample profile ID:', sampleProfile?.id, sampleProfile?.firstName);

  if (sampleProfile?.id) {
    const toggleData = JSON.stringify({ targetProfileId: sampleProfile.id });
    const toggleRes = await request({
      hostname: host,
      port: Number(port),
      path: '/api/v1/shortlists/toggle',
      method: 'POST',
      headers: {
        ...authHeaders,
        'Content-Length': toggleData.length
      }
    }, toggleData);
    console.log('POST /api/v1/shortlists/toggle:', toggleRes.status, toggleRes.body || toggleRes.raw);

    // Check /shortlists again
    const listRes2 = await request({
      hostname: host,
      port: Number(port),
      path: '/api/v1/shortlists',
      method: 'GET',
      headers: authHeaders
    });
    console.log('GET /api/v1/shortlists after toggle:', listRes2.status, Array.isArray(listRes2.body) ? listRes2.body.length : listRes2.body);
  }
})();
