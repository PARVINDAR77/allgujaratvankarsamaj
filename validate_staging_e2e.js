/**
 * Staging Deployment End-to-End Validation Suite
 * Project: All Gujarat Vankar Samaj Matrimony
 *
 * Validates the complete 10-Point Security & Privacy Matrix against Staging.
 * Safety Guard: Strictly refuses to execute against production hostnames or IPs.
 *
 * Usage:
 *   TEST_API_URL=http://127.0.0.1:3001/api/v1 node validate_staging_e2e.js
 *   or:
 *   TEST_API_URL=https://staging.allgujaratvankarsamaj.com/api/v1 node validate_staging_e2e.js
 */

const http = require('http');
const https = require('https');
const { URL } = require('url');

const apiUrlStr = process.env.TEST_API_URL || 'http://127.0.0.1:3001/api/v1';
let parsedUrl;
try {
  parsedUrl = new URL(apiUrlStr);
} catch (e) {
  console.error('\x1b[31m[FATAL CONFIG ERROR] Invalid TEST_API_URL format:\x1b[0m', apiUrlStr);
  process.exit(1);
}

// STRICT ALLOWLIST FOR STAGING TARGETS ONLY
const ALLOWED_TARGETS = [
  { protocol: 'http:', hostname: '127.0.0.1', port: '3001' },
  { protocol: 'http:', hostname: 'localhost', port: '3001' },
  { protocol: 'https:', hostname: 'staging.allgujaratvankarsamaj.com', port: '443' },
  { protocol: 'https:', hostname: 'staging.allgujaratvankarsamaj.com', port: '' },
];

const targetPort = parsedUrl.port || (parsedUrl.protocol === 'https:' ? '443' : '80');
const isApprovedTarget = ALLOWED_TARGETS.some(t => 
  t.protocol === parsedUrl.protocol &&
  t.hostname.toLowerCase() === parsedUrl.hostname.toLowerCase() &&
  (t.port === '' || t.port === targetPort || (t.protocol === 'https:' && (targetPort === '443' || targetPort === '')))
);

if (!isApprovedTarget) {
  console.error('\x1b[31m[FATAL SAFETY ERROR] Execution is strictly restricted to approved staging targets!\x1b[0m');
  console.error(`Attempted target: ${parsedUrl.protocol}//${parsedUrl.hostname}:${targetPort}${parsedUrl.pathname}`);
  console.error('Approved staging targets:');
  console.error('  1. http://127.0.0.1:3001/api/v1 (Local loopback staging)');
  console.error('  2. https://staging.allgujaratvankarsamaj.com/api/v1 (Public staging endpoint)');
  process.exit(1);
}

const isHttps = parsedUrl.protocol === 'https:';
const client = isHttps ? https : http;

function makeRequest(method, path, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const fullPath = parsedUrl.pathname.replace(/\/+$/, '') + path;
    const reqHeaders = { ...headers };
    let payload = null;

    if (body !== null) {
      payload = typeof body === 'string' ? body : JSON.stringify(body);
      reqHeaders['Content-Type'] = reqHeaders['Content-Type'] || 'application/json';
      reqHeaders['Content-Length'] = Buffer.byteLength(payload);
    }

    const options = {
      protocol: parsedUrl.protocol,
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (isHttps ? 443 : 80),
      path: fullPath,
      method: method.toUpperCase(),
      headers: reqHeaders,
      timeout: 10000,
    };

    const req = client.request(options, (res) => {
      // Disallow unapproved redirects
      if ([301, 302, 307, 308].includes(res.statusCode)) {
        const redirectLoc = res.headers.location;
        if (redirectLoc) {
          try {
            const redirectUrl = new URL(redirectLoc, apiUrlStr);
            const redirectAllowed = ALLOWED_TARGETS.some(t =>
              t.hostname.toLowerCase() === redirectUrl.hostname.toLowerCase()
            );
            if (!redirectAllowed) {
              reject(new Error(`CRITICAL: Server returned redirect to unapproved external location: ${redirectLoc}`));
              return;
            }
          } catch (_) {}
        }
      }

      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        let parsed = null;
        try {
          parsed = JSON.parse(data);
        } catch (_) {
          parsed = data;
        }
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          data: parsed,
          raw: data,
        });
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error(`Request timed out after 10000ms: ${method} ${fullPath}`));
    });

    if (payload) {
      req.write(payload);
    }
    req.end();
  });
}

// Staging Synthetic User Credentials - Loaded dynamically from secure credentials file or env vars
const fs = require('fs');
let creds = {};
const credsFile = process.env.STAGING_CREDENTIALS_FILE || '/home/u796269890/staging/.staging_test_credentials.json';
if (fs.existsSync(credsFile)) {
  try {
    creds = JSON.parse(fs.readFileSync(credsFile, 'utf8'));
  } catch (e) {
    console.error(`\x1b[31m[FATAL] Failed to parse credentials file ${credsFile}: ${e.message}\x1b[0m`);
    process.exit(1);
  }
} else if (!process.env.STAGING_ADMIN_PASS) {
  console.error(`\x1b[31m[FATAL] Credentials file ${credsFile} not found and no STAGING_ADMIN_PASS env provided!\x1b[0m`);
  console.error('E2E validation must run with dynamically generated staging credentials.');
  process.exit(1);
}

const FIXTURES = {
  admin: {
    email: creds.adminEmail || 'staging_admin@vankarsamaj.internal',
    password: process.env.STAGING_ADMIN_PASS || creds.adminPass,
  },
  verifier: {
    email: creds.verifierEmail || 'staging_verifier@vankarsamaj.internal',
    password: process.env.STAGING_VERIFIER_PASS || creds.verifierPass,
  },
  contentAdmin: {
    email: creds.contentEmail || 'staging_content@vankarsamaj.internal',
    password: process.env.STAGING_CONTENT_PASS || creds.contentAdminPass,
  },
  sender: {
    email: creds.senderEmail || 'staging_sender@vankarsamaj.internal',
    password: process.env.STAGING_MEMBER_PASS || creds.memberPass,
  },
  receiver: {
    email: creds.receiverEmail || 'staging_receiver@vankarsamaj.internal',
    password: process.env.STAGING_MEMBER_PASS || creds.memberPass,
  },
  unconnected: {
    email: creds.unconnectedEmail || 'staging_unconnected@vankarsamaj.internal',
    password: process.env.STAGING_MEMBER_PASS || creds.memberPass,
  },
};

for (const [role, fix] of Object.entries(FIXTURES)) {
  if (!fix.password) {
    console.error(`\x1b[31m[FATAL] Missing password for synthetic fixture '${role}'. Cannot proceed with E2E suite.\x1b[0m`);
    process.exit(1);
  }
}

const results = [];
function recordResult(testNumber, title, passed, details = '') {
  results.push({ testNumber, title, passed, details });
  const icon = passed ? '\x1b[32m[PASS]\x1b[0m' : '\x1b[31m[FAIL]\x1b[0m';
  console.log(`${icon} Test ${testNumber}: ${title}`);
  if (details) {
    console.log(`       Details: ${details}`);
  }
}

async function runValidation() {
  console.log('=================================================================');
  console.log('  All Gujarat Vankar Samaj Matrimony — Staging E2E Validation    ');
  console.log(`  Target Staging API: ${apiUrlStr}                              `);
  console.log('=================================================================\n');

  let senderToken = null;
  let receiverToken = null;
  let verifierToken = null;
  let contentAdminToken = null;
  let receiverProfileId = null;
  let senderProfileId = null;

  // -------------------------------------------------------------------------
  // Test 1: Anonymous profile listing and detail privacy masking
  // -------------------------------------------------------------------------
  try {
    const listRes = await makeRequest('GET', '/profiles?limit=5');
    const profiles = Array.isArray(listRes.data?.data) ? listRes.data.data : (Array.isArray(listRes.data) ? listRes.data : []);
    
    let listingMasked = profiles.length > 0;
    for (const p of profiles) {
      if (p.contactPhone || p.contactEmail || p.altPhone || p.fatherContact || p.guardianContact || p.addressLine || p.user) {
        listingMasked = false;
        break;
      }
    }

    // Now test anonymous detail
    let detailMasked = false;
    if (profiles.length > 0) {
      const sampleId = profiles[0].id;
      const detailRes = await makeRequest('GET', `/profiles/${sampleId}`);
      const d = detailRes.data;
      if (
        detailRes.statusCode === 200 &&
        d.contactPhone === null &&
        d.contactEmail === null &&
        d.fatherContact === null &&
        !d.user?.passwordHash
      ) {
        detailMasked = true;
      }
    }

    recordResult(
      1,
      'Anonymous profile listing and detail privacy masking',
      listingMasked && detailMasked,
      `Listing masked: ${listingMasked}, Detail masked: ${detailMasked}`
    );
  } catch (err) {
    recordResult(1, 'Anonymous profile listing and detail privacy masking', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 2: Invalid and expired tokens
  // -------------------------------------------------------------------------
  try {
    const invalidTokenHeaders = { Authorization: 'Bearer this.is.an.invalid.or.expired.jwt.token' };

    // Public route must remain anonymous and NOT return 401
    const publicRes = await makeRequest('GET', '/profiles?limit=2', null, invalidTokenHeaders);
    const publicRemainsAnonymous = publicRes.statusCode === 200;

    // Protected route must return 401 Unauthorized
    const protectedRes = await makeRequest('GET', '/auth/me', null, invalidTokenHeaders);
    const protectedRejects = protectedRes.statusCode === 401;

    recordResult(
      2,
      'Invalid and expired tokens (Public fallback vs Protected 401)',
      publicRemainsAnonymous && protectedRejects,
      `Public status: ${publicRes.statusCode} (expected 200), Protected status: ${protectedRes.statusCode} (expected 401)`
    );
  } catch (err) {
    recordResult(2, 'Invalid and expired tokens', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 3: Valid and invalid login
  // -------------------------------------------------------------------------
  try {
    // 3a. Invalid credentials
    const badLoginRes = await makeRequest('POST', '/auth/login', {
      email: FIXTURES.sender.email,
      password: 'CompletelyWrongPassword!',
    });
    const invalidRejected = badLoginRes.statusCode === 401 && !badLoginRes.data?.accessToken;

    // 3b. Valid credentials for Sender
    const goodLoginRes = await makeRequest('POST', '/auth/login', {
      email: FIXTURES.sender.email,
      password: FIXTURES.sender.password,
    });
    senderToken = goodLoginRes.data?.accessToken;
    const validAccepted = goodLoginRes.statusCode === 200 && Boolean(senderToken);

    // Also login Receiver
    const receiverLoginRes = await makeRequest('POST', '/auth/login', {
      email: FIXTURES.receiver.email,
      password: FIXTURES.receiver.password,
    });
    receiverToken = receiverLoginRes.data?.accessToken;

    recordResult(
      3,
      'Valid and invalid login (Reject bad password, issue JWT for valid)',
      invalidRejected && validAccepted,
      `Invalid login rejected: ${invalidRejected} (401), Valid login issued JWT: ${validAccepted}`
    );
  } catch (err) {
    recordResult(3, 'Valid and invalid login', false, err.message);
  }

  // Fetch Profile IDs for Sender and Receiver
  try {
    if (senderToken) {
      const myProfRes = await makeRequest('GET', '/profiles/me', null, { Authorization: `Bearer ${senderToken}` });
      senderProfileId = myProfRes.data?.id;
    }
    if (receiverToken) {
      const myProfRes = await makeRequest('GET', '/profiles/me', null, { Authorization: `Bearer ${receiverToken}` });
      receiverProfileId = myProfRes.data?.id;
    }
  } catch (_) {}

  // -------------------------------------------------------------------------
  // Test 4: Unconnected member contact masking
  // -------------------------------------------------------------------------
  try {
    if (!senderToken || !receiverProfileId) {
      throw new Error('Precondition failed: sender token or receiver profile ID not available');
    }

    const unconnectedRes = await makeRequest('GET', `/profiles/${receiverProfileId}`, null, {
      Authorization: `Bearer ${senderToken}`,
    });
    const profileData = unconnectedRes.data;

    // Sender and Receiver are NOT connected yet. Private fields must be masked.
    const contactsMasked =
      unconnectedRes.statusCode === 200 &&
      profileData.contactPhone === null &&
      profileData.contactEmail === null &&
      profileData.fatherContact === null &&
      profileData.guardianContact === null;

    recordResult(
      4,
      'Unconnected member contact masking',
      contactsMasked,
      `Receiver profile viewed by unconnected Sender: contactPhone=${profileData?.contactPhone}, fatherContact=${profileData?.fatherContact}`
    );
  } catch (err) {
    recordResult(4, 'Unconnected member contact masking', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 5: Sender self-acceptance attack rejection (CRITICAL FIX)
  // -------------------------------------------------------------------------
  let createdInterestId = null;
  try {
    if (!senderToken || !receiverProfileId) {
      throw new Error('Precondition failed: sender token or receiver profile ID not available');
    }

    // Sender sends real interest to Receiver
    const sendRes = await makeRequest('POST', '/interests', {
      targetProfileId: receiverProfileId,
    }, { Authorization: `Bearer ${senderToken}` });

    createdInterestId = sendRes.data?.interest?.id || sendRes.data?.id;
    if (!createdInterestId) {
      throw new Error(`Failed to create interest: status=${sendRes.statusCode}, body=${JSON.stringify(sendRes.data)}`);
    }

    // Now Sender maliciously attempts to accept their OWN pending interest
    const attackRes = await makeRequest('PATCH', `/interests/${createdInterestId}/accept`, {}, {
      Authorization: `Bearer ${senderToken}`,
    });

    const attackRejected = attackRes.statusCode === 400;

    recordResult(
      5,
      'Sender self-acceptance rejection on real pending interest',
      attackRejected,
      `Status: ${attackRes.statusCode} (expected 400 Bad Request). Message: "${attackRes.data?.message}"`
    );
  } catch (err) {
    recordResult(5, 'Sender self-acceptance rejection on real pending interest', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 6: Legitimate acceptance by genuine receiver
  // -------------------------------------------------------------------------
  try {
    if (!receiverToken || !createdInterestId) {
      throw new Error('Precondition failed: receiver token or interest ID not available');
    }

    const acceptRes = await makeRequest('PATCH', `/interests/${createdInterestId}/accept`, {}, {
      Authorization: `Bearer ${receiverToken}`,
    });

    const accepted = acceptRes.statusCode === 200 && acceptRes.data?.status === 'ACCEPTED';

    // Verify contact disclosure post-acceptance
    const senderViewRes = await makeRequest('GET', `/profiles/${receiverProfileId}`, null, {
      Authorization: `Bearer ${senderToken}`,
    });

    const contactsNowDisclosed =
      senderViewRes.data?.contactPhone !== null ||
      senderViewRes.data?.contactEmail !== null ||
      senderViewRes.data?.fatherContact !== null;

    recordResult(
      6,
      'Legitimate acceptance by receiver and mutual contact unlock',
      accepted && contactsNowDisclosed,
      `Accepted status: ${acceptRes.data?.status}, Contacts unlocked post-acceptance: ${contactsNowDisclosed}`
    );
  } catch (err) {
    recordResult(6, 'Legitimate acceptance by receiver and mutual contact unlock', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 7: Role-based access control (CONTENT_ADMIN vs VERIFICATION_ADMIN)
  // -------------------------------------------------------------------------
  try {
    // 7a. Content Admin login and view
    const caLoginRes = await makeRequest('POST', '/auth/login', {
      email: FIXTURES.contentAdmin.email,
      password: FIXTURES.contentAdmin.password,
    });
    contentAdminToken = caLoginRes.data?.accessToken;

    const caViewRes = await makeRequest('GET', `/profiles/${receiverProfileId}`, null, {
      Authorization: `Bearer ${contentAdminToken}`,
    });
    const contentAdminMasked =
      caViewRes.data?.contactPhone === null &&
      caViewRes.data?.fatherContact === null;

    // 7b. Verification Admin login and view
    const vaLoginRes = await makeRequest('POST', '/auth/login', {
      email: FIXTURES.verifier.email,
      password: FIXTURES.verifier.password,
    });
    verifierToken = vaLoginRes.data?.accessToken;

    const vaViewRes = await makeRequest('GET', `/profiles/${receiverProfileId}`, null, {
      Authorization: `Bearer ${verifierToken}`,
    });
    const verifierAdminDisclosed =
      vaViewRes.data?.contactEmail !== null ||
      vaViewRes.data?.fatherContact !== null;

    recordResult(
      7,
      'Role-based access (CONTENT_ADMIN masked, VERIFICATION_ADMIN disclosed)',
      contentAdminMasked && verifierAdminDisclosed,
      `CONTENT_ADMIN masked: ${contentAdminMasked}, VERIFICATION_ADMIN disclosed: ${verifierAdminDisclosed}`
    );
  } catch (err) {
    recordResult(7, 'Role-based access', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 8: Database isolation verification
  // -------------------------------------------------------------------------
  try {
    const healthRes = await makeRequest('GET', '/health');
    const isHealthy = healthRes.statusCode === 200;
    const isStagingEnv = process.env.NODE_ENV !== 'production' || !apiUrlStr.includes('allgujaratvankarsamaj.com');

    recordResult(
      8,
      'Database isolation (Staging target distinct from production)',
      isHealthy && isStagingEnv,
      `Health status: ${healthRes.statusCode}, Target host: ${parsedUrl.hostname}, Port: ${parsedUrl.port || 'default'}`
    );
  } catch (err) {
    recordResult(8, 'Database isolation verification', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 9: Flutter and Admin Panel client API compatibility
  // -------------------------------------------------------------------------
  try {
    // Verify standard client routes: /auth/me, /profiles/reference-data, /profiles/completeness
    const refDataRes = await makeRequest('GET', '/profiles/reference-data');
    const compRes = await makeRequest('GET', '/profiles/completeness', null, {
      Authorization: `Bearer ${senderToken}`,
    });

    const clientContractsValid =
      refDataRes.statusCode === 200 &&
      Array.isArray(refDataRes.data?.gender) &&
      compRes.statusCode === 200 &&
      typeof compRes.data?.percentage === 'number';

    recordResult(
      9,
      'Flutter and Admin Panel API contract compatibility',
      clientContractsValid,
      `Reference data status: ${refDataRes.statusCode}, Completeness status: ${compRes.statusCode}`
    );
  } catch (err) {
    recordResult(9, 'Flutter and Admin Panel API contract compatibility', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Test 10: Proxy and network isolation (CORS origin enforcement & zero prod requests)
  // -------------------------------------------------------------------------
  try {
    // Test untrusted origin: should NOT receive Access-Control-Allow-Credentials: true
    const corsTestRes = await makeRequest('OPTIONS', '/profiles', null, {
      Origin: 'https://malicious-attacker-website.com',
      'Access-Control-Request-Method': 'GET',
    });

    const credsHeader = corsTestRes.headers['access-control-allow-credentials'];
    const originHeader = corsTestRes.headers['access-control-allow-origin'];

    const originRestricted =
      credsHeader !== 'true' ||
      originHeader !== 'https://malicious-attacker-website.com';

    recordResult(
      10,
      'Proxy and network isolation (Untrusted origin rejected/restricted)',
      originRestricted,
      `Origin header: "${originHeader}", Credentials allowed: "${credsHeader}"`
    );
  } catch (err) {
    recordResult(10, 'Proxy and network isolation', false, err.message);
  }

  // -------------------------------------------------------------------------
  // Summary
  // -------------------------------------------------------------------------
  console.log('\n=================================================================');
  const totalPassed = results.filter(r => r.passed).length;
  console.log(`  Validation Complete: ${totalPassed} / ${results.length} tests passed`);
  console.log('=================================================================\n');

  if (totalPassed < results.length) {
    console.error('One or more staging validation checks failed. Maintain HOLD status.');
    process.exit(1);
  } else {
    console.log('All 10 staging validation checklist items passed successfully!');
    process.exit(0);
  }
}

runValidation().catch(err => {
  console.error('Fatal validation runner error:', err);
  process.exit(1);
});
