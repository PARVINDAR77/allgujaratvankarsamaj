const http = require('http');
const crypto = require('crypto');

const PORT = 3000;
const HOST = '127.0.0.1';

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: HOST,
      port: PORT,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };
    if (token) {
      options.headers['Cookie'] = `admin_token=${token}`;
    }
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (c) => data += c);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: data ? JSON.parse(data) : null });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });
    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

// Just to get auth token without cookies, we can use the regular API, but admin endpoints require the cookie.
function login(email, password) {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: HOST, port: PORT, path: '/api/v1/auth/login', method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (res) => {
      let data = '';
      let cookies = res.headers['set-cookie'] || [];
      let token = null;
      for (const c of cookies) {
        if (c.startsWith('admin_token=')) {
          token = c.split(';')[0].split('=')[1];
        }
      }
      res.on('data', (c) => data += c);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data), token }));
    });
    req.on('error', reject);
    req.write(JSON.stringify({ email, password }));
    req.end();
  });
}

function register(email, password) {
  return request('POST', '/api/v1/auth/register', { email, password });
}

async function run() {
  console.log('--- Phase 23 Users/Profile Admin E2E Tests ---');

  // 1. Create a normal user
  const email = `user_${Date.now()}@test.com`;
  await register(email, 'password123');

  // Login as normal user
  const userRes = await login(email, 'password123');
  const userToken = userRes.token;

  // Login as Admin Manager (Seeded as ADMIN)
  const adminRes = await login('admin@vankarsamaj.org', 'admin123');
  const adminToken = adminRes.token;

  // 1. Unauthenticated GET users -> 401
  const r1 = await request('GET', '/api/v1/admin/users');
  console.log(`[Test] Unauthenticated -> ${r1.status} (Expected: 401)`);

  // 2. No MEMBERS_READ -> 403 (A regular user doesn't have MEMBERS_READ)
  const r2 = await request('GET', '/api/v1/admin/users', null, userToken);
  console.log(`[Test] No MEMBERS_READ -> ${r2.status} (Expected: 403)`);

  // 3. MEMBERS_READ -> GET succeeds (Admin Manager has MEMBERS_READ)
  const r3 = await request('GET', '/api/v1/admin/users', null, adminToken);
  console.log(`[Test] MEMBERS_READ -> ${r3.status} (Expected: 200)`);
  
  if (r3.status === 200) {
    const users = r3.body;
    console.log(`Loaded ${users.length} users. Protected fields excluded: ${!users[0].passwordHash ? 'Yes' : 'No'}`);
    
    // Find the newly created user to mutate
    const targetUser = users.find(u => u.email === email);
    if (!targetUser) {
      console.log('User not found in list!');
      return;
    }
    const targetUserId = targetUser.id;

    // 4. No MEMBERS_UPDATE -> mutation 403
    const r4 = await request('PATCH', `/api/v1/admin/users/${targetUserId}/status`, { status: 'INACTIVE' }, userToken);
    console.log(`[Test] No MEMBERS_UPDATE -> ${r4.status} (Expected: 403)`);

    // 5. MEMBERS_UPDATE -> status mutation succeeds
    const r5 = await request('PATCH', `/api/v1/admin/users/${targetUserId}/status`, { status: 'INACTIVE' }, adminToken);
    console.log(`[Test] MEMBERS_UPDATE -> ${r5.status} (Expected: 200)`);

    // Validate Audit Log directly using Prisma
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    
    const auditLogs = await prisma.adminAuditLog.findMany({
      where: { entityId: targetUserId, action: "UPDATE_USER_STATUS" }
    });
    console.log(`[Test] Audit Logs created: ${auditLogs.length} (Expected: 1)`);
    if (auditLogs.length > 0) {
      const log = auditLogs[0];
      console.log(`   Old: ${log.oldValue}, New: ${log.newValue}`);
    }

    // 6. Invalid user ID -> 404
    const r6 = await request('PATCH', `/api/v1/admin/users/invalid-id/status`, { status: 'ACTIVE' }, adminToken);
    console.log(`[Test] Invalid user ID -> ${r6.status} (Expected: 404)`);

    // 7. Invalid status -> 400
    const r7 = await request('PATCH', `/api/v1/admin/users/${targetUserId}/status`, { status: 'INVALID_STATUS' }, adminToken);
    console.log(`[Test] Invalid status -> ${r7.status} (Expected: 400)`);

    // 8. Role escalation attempt (Admin -> Super Admin) -> rejected
    const r8 = await request('PATCH', `/api/v1/admin/users/${targetUserId}/role`, { role: 'SUPER_ADMIN' }, adminToken);
    console.log(`[Test] Role escalation by ADMIN -> ${r8.status} (Expected: 403)`);

    // To test role change success, we need to login as SUPER_ADMIN (Parvindar)
    const superAdminRes = await login('panjabiparvindar77@gmail.com', 'password123');
    if (superAdminRes.status === 200) {
      const r9 = await request('PATCH', `/api/v1/admin/users/${targetUserId}/role`, { role: 'ADMIN' }, superAdminRes.token);
      console.log(`[Test] Role update by SUPER_ADMIN -> ${r9.status} (Expected: 200)`);

      const roleLogs = await prisma.adminAuditLog.findMany({
        where: { entityId: targetUserId, action: "UPDATE_USER_ROLE" }
      });
      console.log(`[Test] Role Audit Logs created: ${roleLogs.length} (Expected: 1)`);
    }

    await prisma.$disconnect();
  }
}

run().catch(console.error);
