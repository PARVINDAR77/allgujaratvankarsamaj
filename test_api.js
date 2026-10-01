const https = require('https');

const data = JSON.stringify({
  email: 'panjabiparvindar77@gmail.com',
  password: 'Password123'
});

const options = {
  hostname: 'allgujaratvankarsamaj.com',
  port: 443,
  path: '/api/v1/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, res => {
  console.log(`statusCode: ${res.statusCode}`);
  let body = '';
  res.on('data', d => {
    body += d;
  });
  res.on('end', () => {
    console.log('--- BODY START ---');
    console.log(body);
    console.log('--- BODY END ---');
    console.log('Body length:', body.length);
    console.log('Type of parsed JSON:', typeof JSON.parse(body));
    console.log('Is Array?', Array.isArray(JSON.parse(body)));
  });
});

req.on('error', error => {
  console.error(error);
});

req.write(data);
req.end();
