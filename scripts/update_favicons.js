const fs = require('fs');
const path = require('path');

function updateIndex(file) {
  if (!fs.existsSync(file)) return;
  let html = fs.readFileSync(file, 'utf8');

  // Replace apple-touch-icon and favicon section
  const target = '<link rel="apple-touch-icon" href="icons/Icon-192.png">';
  const replacement = [
    '<!-- Favicons & App Icons (Official All Gujarat Vankar Samaj Emblem) -->',
    '  <link rel="shortcut icon" href="favicon.ico?v=85" type="image/x-icon">',
    '  <link rel="icon" href="favicon.ico?v=85" type="image/x-icon">',
    '  <link rel="icon" type="image/png" sizes="16x16" href="favicon-16x16.png?v=85">',
    '  <link rel="icon" type="image/png" sizes="32x32" href="favicon-32x32.png?v=85">',
    '  <link rel="icon" type="image/png" sizes="48x48" href="favicon-48x48.png?v=85">',
    '  <link rel="icon" type="image/png" sizes="96x96" href="favicon-96x96.png?v=85">',
    '  <link rel="icon" type="image/png" sizes="192x192" href="icons/Icon-192.png?v=85">',
    '  <link rel="apple-touch-icon" sizes="180x180" href="icons/Icon-192.png?v=85">',
    '  <link rel="apple-touch-icon" sizes="192x192" href="icons/Icon-192.png?v=85">'
  ].join('\n  ');

  if (html.includes(target)) {
    html = html.replace(target, replacement);
  }

  // Replace <link rel="icon" type="image/png" href="favicon.png"/>
  html = html.replace(/<link rel="icon" type="image\/png" href="favicon\.png"\s*\/?>/g, '<link rel="icon" type="image/png" href="favicon.png?v=85"/>');

  // Update manifest version
  html = html.replace(/href="manifest\.json(\?[^"]*)?"/g, 'href="manifest.json?v=85"');

  // Update cache buster
  html = html.replace(/var CURRENT_BUILD = '[^']+';/g, "var CURRENT_BUILD = '20261117_official_favicon_v85';");

  fs.writeFileSync(file, html, 'utf8');
  console.log('Successfully updated:', file);
}

updateIndex(path.join(__dirname, '..', 'application', 'build', 'web', 'index.html'));
updateIndex(path.join(__dirname, '..', 'application', 'web', 'index.html'));
