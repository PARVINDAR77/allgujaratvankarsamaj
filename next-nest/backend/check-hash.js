const bcrypt = require('bcrypt');

async function check() {
  const hash = "$2b$10$XgjQCZtgKsEaxKyLNVqN2u8eazjrOxtijj.p.2Pxj/LmQNu0y8hvm";
  const isValid = await bcrypt.compare("password123", hash);
  console.log("Is valid:", isValid);
  
  const p1 = await bcrypt.compare("Password123", hash);
  console.log("Is Password123:", p1);
}

check();
