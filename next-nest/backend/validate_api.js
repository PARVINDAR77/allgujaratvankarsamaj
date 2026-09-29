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
          resolve({ status: res.statusCode, data: parsed });
        } catch(e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });
    req.on('error', reject);
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- Phase 6 API Validation ---');
  try {
    let res = await request('/api/v1/health');
    console.log('[Health] GET /api/v1/health ->', res.status, res.data.status || 'OK');

    const testEmail = `test_user_${Date.now()}@example.com`;
    const password = 'Password@123';
    res = await request('/api/v1/auth/register', {
      method: 'POST',
      body: { email: testEmail, password }
    });
    console.log('[Auth] Register ->', res.status);
    
    res = await request('/api/v1/auth/login', {
      method: 'POST',
      body: { email: testEmail, password }
    });
    console.log('[Auth] Login ->', res.status);
    
    const token = res.data.accessToken || res.data.access_token || res.data.token;
    if (!token) {
        console.log('Login Response:', res.data);
        throw new Error('No JWT returned');
    }
    
    res = await request('/api/v1/auth/me', {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('[Auth] /me ->', res.status, res.data.email);

    res = await request('/api/v1/profiles', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: {
        firstName: 'Test', lastName: 'User', gender: 'MALE', dateOfBirth: '1995-01-01',
        maritalStatus: 'NEVER_MARRIED', religion: 'Hindu', caste: 'Vankar Samaj',
        city: 'Ahmedabad', state: 'Gujarat', country: 'India',
        education: 'BE', occupation: 'Engineer', about: 'Test profile'
      }
    });
    console.log('[Profile] Create ->', res.status);
    
    res = await request('/api/v1/profiles/me', {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('[Profile] GET /me ->', res.status, res.data.firstName);

    res = await request('/api/v1/states');
    console.log('[Locations] GET /states ->', res.status, Array.isArray(res.data) ? `Count: ${res.data.length}` : 'Error');

    res = await request('/api/v1/samaj-services');
    console.log('[SamajServices] GET /samaj-services ->', res.status, Array.isArray(res.data) ? `Count: ${res.data.length}` : 'Error');

  } catch(err) {
    console.error('Test Error:', err.message);
  }
}

runTests();
