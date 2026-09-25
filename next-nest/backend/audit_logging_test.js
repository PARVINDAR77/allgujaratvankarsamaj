const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const prisma = new PrismaClient();

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

async function runAuditLogTests() {
  console.log('--- STARTING PHASE 30 AUDIT LOGGING TEST ---');

  const timestamp = Date.now();
  const userEmail = `victim_audit_${timestamp}@example.com`;
  const password = 'Password123!';

  try {
    // 1. Setup User
    console.log('\n[Setup] Registering dummy user...');
    await apiCall('/auth/register', 'POST', { email: userEmail, password });
    
    // Admin login
    let adminLogin = await apiCall('/auth/login', 'POST', { email: 'admin@vankarsamaj.com', password: 'password123' });
    if (!adminLogin.data?.accessToken) {
       adminLogin = await apiCall('/auth/login', 'POST', { email: 'admin@vankarsamaj.com', password: 'Admin@123' });
    }
    const adminToken = adminLogin.data.accessToken;

    if (!adminToken) {
       console.error("Admin login failed!");
       process.exit(1);
    }

    // Get User ID
    const user = await prisma.user.findUnique({ where: { email: userEmail }});
    const userId = user.id;

    // 2. Perform Sensitive Action
    console.log('\n[Action] Admin updates user status to INACTIVE...');
    const suspendRes = await apiCall(`/admin/users/${userId}/status`, 'PATCH', { status: 'INACTIVE' }, adminToken);
    
    if (suspendRes.status !== 200) {
      console.error('Failed to suspend user', suspendRes.status, suspendRes.data);
      process.exit(1);
    }

    // 3. Verify Audit Log was generated
    console.log('\n[Verify] Querying Database for Audit Log entry...');
    const auditLogs = await prisma.adminAuditLog.findMany({
      where: {
        entityId: userId,
        action: 'UPDATE_USER_STATUS'
      },
      orderBy: { createdAt: 'desc' },
      take: 1
    });

    if (auditLogs.length === 0) {
      console.error('❌ [FAIL] Audit Log was NOT generated!');
      process.exit(1);
    }

    const log = auditLogs[0];
    console.log(`✅ [PASS] Audit Log Found:`);
    console.log(`   Action:     ${log.action}`);
    console.log(`   Entity:     ${log.entityType}`);
    console.log(`   Entity ID:  ${log.entityId}`);
    console.log(`   Before:     ${log.oldValue}`);
    console.log(`   After:      ${log.newValue}`);
    console.log(`   Timestamp:  ${log.createdAt}`);
    console.log(`   IP Address: ${log.ipAddress}`);

    if (log.ipAddress && ['127.0.0.1', '::1', '::ffff:127.0.0.1'].includes(log.ipAddress)) {
      console.log(`✅ [PASS] IP Address was recorded correctly (${log.ipAddress})`);
    } else {
      console.error(`❌ [FAIL] IP Address was NOT recorded or invalid: ${log.ipAddress}`);
      process.exit(1);
    }

    console.log(`\n=== PHASE 30 AUDIT LOGGING VERIFICATION SUCCESSFUL! ===\n`);
    process.exit(0);
  } catch (err) {
    console.error('Fatal Test Error:', err);
    process.exit(1);
  }
}

runAuditLogTests();
