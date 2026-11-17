const fs = require('fs');
const path = require('path');

const OLD_TAG = '20261117_clean_pargana_v80';
const NEW_TAG = '20261117_services_profile_v82';

const files = [
  path.join(__dirname, '../application/build/web/index.html'),
  path.join(__dirname, '../application/build/web/flutter_bootstrap.js'),
  path.join(__dirname, '../application/web/index.html'),
  path.join(__dirname, '../application/web/flutter_bootstrap.js')
];

for (const f of files) {
  if (fs.existsSync(f)) {
    let content = fs.readFileSync(f, 'utf8');
    if (content.includes(OLD_TAG)) {
      content = content.replaceAll(OLD_TAG, NEW_TAG);
      fs.writeFileSync(f, content, 'utf8');
      console.log('Bumped cache tag in', f);
    } else {
      console.log('Tag not found in', f);
    }
  }
}

// Update version.json
const verFile = path.join(__dirname, '../application/build/web/version.json');
if (fs.existsSync(verFile)) {
  fs.writeFileSync(verFile, JSON.stringify({
    app_name: 'application',
    version: '1.0.14',
    build_number: '15',
    package_name: 'application'
  }, null, 2), 'utf8');
  console.log('Updated version.json');
}
