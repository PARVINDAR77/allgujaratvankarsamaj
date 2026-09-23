const fs = require('fs');
const path = 'd:/vankarsamajmatrimony/next-nest/frontend/src/lib/admin-api.ts';
let code = fs.readFileSync(path, 'utf8');

// Replace /admin/stats with /admin/statistics/dashboard
code = code.replace(/\/admin\/stats/g, '/admin/statistics/dashboard');

// Strip out mock data catch block for dashboard
code = code.replace(/catch\s*\([^)]+\)\s*\{\s*console\.warn\([\s\S]*?recentVerifications:\s*\[\],\s*\};\s*\}/, 'catch (error) { throw error; }');

// Strip out standard catch blocks returning arrays or objects
code = code.replace(/catch\s*\{\s*return\s*\[[\s\S]*?\];\s*\}/g, 'catch (error) { throw error; }');
code = code.replace(/catch\s*\{\s*return\s*\{[\s\S]*?\};\s*\}/g, 'catch (error) { throw error; }');

fs.writeFileSync(path, code);
console.log("Done");
