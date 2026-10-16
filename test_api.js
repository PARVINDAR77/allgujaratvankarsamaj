const https = require('https');
const http = require('http');

const host = process.env.TEST_API_HOST || '127.0.0.1';
const port = process.env.TEST_API_PORT || 3000;
const email = process.env.TEST_USER_EMAIL || 'test-user@example.test';
const password = process.env.TEST_USER_PASSWORD || 'TestPassword123!';

if (host.includes('allgujaratvankarsamaj.com') || host.includes('217.21.94.138')) {
  console.error('SECURITY VIOLATION: Execution against production domain or IP is strictly prohibited.');
  process.exit(1);
}

const data = JSON.stringify({ email, password });
const client = Number(port) === 443 ? https : http;

const options = {
  hostname: host,
  port: Number(port),
  path: '/api/v1/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data),
  },
};

const req = client.request(options, res => {
  console.log(`statusCode: ${res.statusCode}`);
  let body = '';
  res.on('data', d => { body += d; });
  res.on('end', () => {
    console.log('Response status:', res.statusCode);
    try {
      const parsed = JSON.parse(body);
      console.log('Login outcome:', parsed.message || (parsed.accessToken ? 'Token received' : 'No token'));
    } catch (_) {
      console.log('Raw body length:', body.length);
    }
  });
});

req.on('error', error => {
  console.error('Connection error (ensure local test server is running):', error.message);
});

req.write(data);
req.end();
