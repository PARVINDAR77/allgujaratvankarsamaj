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
  console.log('--- Phase 7 Admin Panel Simulation ---');
  try {
    // 1. Admin Login
    let res = await request('/api/v1/auth/login', {
      method: 'POST',
      body: { email: 'admin@vankarsamaj.com', password: 'password123' }
    });
    
    // If password123 didn't work, maybe it's Admin@123
    if (res.status === 401) {
       res = await request('/api/v1/auth/login', {
         method: 'POST',
         body: { email: 'admin@vankarsamaj.com', password: 'Admin@123' }
       });
    }

    if (res.status !== 200 && res.status !== 201) {
      console.log('Failed to login as admin. Response:', res.status, res.data);
      return;
    }
    console.log('[Admin] Login ->', res.status);
    const token = res.data.accessToken || res.data.access_token || res.data.token;
    const authHeaders = { Authorization: `Bearer ${token}` };

    // 2. Admin Dashboard
    res = await request('/api/v1/admin/statistics/dashboard', { headers: authHeaders });
    console.log('[Admin] Dashboard Stats ->', res.status, res.data);

    // 3. Admin Users
    res = await request('/api/v1/admin/users', { headers: authHeaders });
    console.log('[Admin] Users List ->', res.status, Array.isArray(res.data) || Array.isArray(res.data?.data) ? 'OK' : 'Error');

    // 4. Locations Management (Create -> Read -> Update -> Delete)
    // Create
    const stateName = 'Gujarati State ' + Date.now();
    res = await request('/api/v1/locations/admin/states', {
      method: 'POST',
      headers: authHeaders,
      body: { name: stateName, gujaratiName: 'ગુજરાતી રાજ્ય', code: 'GS' }
    });
    console.log('[Locations] Create State ->', res.status);
    const stateId = res.data?.id;

    if (stateId) {
        // Read
        res = await request('/api/v1/locations/states');
        const found = res.data.find(s => s.id === stateId);
        console.log('[Locations] Read State ->', found ? 'Found ✅' : 'Missing ❌');

        // Update
        res = await request(`/api/v1/locations/admin/states/${stateId}`, {
          method: 'PATCH',
          headers: authHeaders,
          body: { gujaratiName: 'ગુજરાતી અપડેટ' }
        });
        console.log('[Locations] Update State ->', res.status, res.data.gujaratiName === 'ગુજરાતી અપડેટ' ? 'Gujarati persistence ✅' : 'Failed ❌');

        // Delete
        res = await request(`/api/v1/locations/admin/states/${stateId}`, {
          method: 'DELETE',
          headers: authHeaders
        });
        console.log('[Locations] Delete State ->', res.status);
    }

    // 5. Samaj Services
    res = await request('/api/v1/admin/samaj-services', { headers: authHeaders });
    console.log('[Admin] Samaj Services ->', res.status);

    // 6. Verifications
    res = await request('/api/v1/admin/verifications', { headers: authHeaders });
    console.log('[Admin] Verifications ->', res.status);

    // 7. Government Employees
    res = await request('/api/v1/admin/government-employees', { headers: authHeaders });
    console.log('[Admin] Government Employees ->', res.status);

    // 8. Advertisements
    res = await request('/api/v1/admin/advertisements', { headers: authHeaders });
    console.log('[Admin] Advertisements ->', res.status);

    // 9. Success Stories
    res = await request('/api/v1/admin/success-stories', { headers: authHeaders });
    console.log('[Admin] Success Stories ->', res.status);

    // 10. Reports
    res = await request('/api/v1/admin/reports', { headers: authHeaders });
    console.log('[Admin] Reports ->', res.status);

  } catch(err) {
    console.error('Test Error:', err.message);
  }
}

runTests();
