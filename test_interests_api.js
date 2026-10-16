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
  if (!token) {
    console.log('Login failed:', loginRes.raw);
    return;
  }

  const authHeaders = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };

  // 2. Check My Profile
  const myProfRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/profile/me',
    method: 'GET',
    headers: authHeaders
  });
  console.log('My Profile status:', myProfRes.status, 'ID:', myProfRes.body?.id, 'Name:', myProfRes.body?.firstName);

  // 3. Check GET /interests/sent
  const sentRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/interests/sent',
    method: 'GET',
    headers: authHeaders
  });
  console.log('Sent interests status:', sentRes.status, 'Count:', sentRes.body?.length);
  console.log('Sent interests sample:', JSON.stringify(sentRes.body?.slice(0, 2)));

  // 4. Check GET /interests/received
  const recvRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/interests/received',
    method: 'GET',
    headers: authHeaders
  });
  console.log('Received interests status:', recvRes.status, 'Count:', recvRes.body?.length);
  console.log('Received interests sample:', JSON.stringify(recvRes.body?.slice(0, 2)));

  // 5. Check GET /user/notifications
  const notifRes = await request({
    hostname: host,
    port: Number(port),
    path: '/api/v1/user/notifications',
    method: 'GET',
    headers: authHeaders
  });
  console.log('User notifications status:', notifRes.status, 'Count:', notifRes.body?.length);
  console.log('User notifications sample:', JSON.stringify(notifRes.body?.slice(0, 2)));
})();
