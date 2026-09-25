const fetch = require("node-fetch"); // or global fetch if Node 18+

async function runTests() {
  console.log("--- Phase 20 Admin Auth Tests ---");
  const API_URL = "http://127.0.0.1:3000/api/v1";
  
  try {
    // 1. Verify unauthenticated access -> 401
    const unauthRes = await fetch(`${API_URL}/admin/statistics/dashboard`);
    console.log(`[Test 1] Unauthenticated request -> ${unauthRes.status} (Expected: 401)`);
    
    // 2. Login and get cookie
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "admin@vankarsamaj.com", password: "password123" })
    });
    
    const setCookie = loginRes.headers.raw()['set-cookie'];
    console.log(`[Test 2] Login -> ${loginRes.status} OK`);
    console.log(`         Set-Cookie Header: ${setCookie}`);
    
    if (!setCookie) {
      throw new Error("No cookie received on login!");
    }
    
    const adminTokenCookie = setCookie[0].split(';')[0];
    
    // 3. Authenticated request using ONLY the cookie
    const authRes = await fetch(`${API_URL}/admin/statistics/dashboard`, {
      headers: {
        "Cookie": adminTokenCookie
      }
    });
    console.log(`[Test 3] Authenticated via Cookie -> ${authRes.status} (Expected: 200 or 403 based on roles)`);
    console.log(await authRes.json());
    
    // 4. Flutter regression: Authenticated request using ONLY Authorization Bearer Header
    const loginBody = await loginRes.json();
    // Wait, the new login doesn't return accessToken in the JSON anymore. We changed it. 
    // Oh! Flutter login calls the same endpoint. If we stopped returning accessToken in the JSON body, Flutter will break!
    console.log("Login JSON body:", Object.keys(loginBody));
    
    if (!loginBody.accessToken) {
      throw new Error("No accessToken returned for Flutter compatibility");
    }
    
    // 4. Flutter regression: Authenticated request using ONLY Authorization Bearer Header
    const bearerRes = await fetch(`${API_URL}/admin/users`, {
      headers: {
        "Authorization": `Bearer ${loginBody.accessToken}`
      }
    });
    console.log(`[Test 4] Authenticated via Bearer Token -> ${bearerRes.status} (Expected: 200 or 403)`);
    const logoutRes = await fetch(`${API_URL}/auth/logout`, {
      method: "POST"
    });
    const clearCookie = logoutRes.headers.raw()['set-cookie'];
    console.log(`[Test 5] Logout -> ${logoutRes.status}`);
    console.log(`         Clear-Cookie Header: ${clearCookie}`);
    
    // 6. Request with old cookie (Note: this is stateless JWT, so it will still succeed if we just send the same cookie again unless we implemented token blacklisting. But the browser clears it.)
    
  } catch (err) {
    console.error("Test error:", err);
  }
}

runTests();
