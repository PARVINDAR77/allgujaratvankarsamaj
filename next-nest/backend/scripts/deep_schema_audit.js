const fs = require('fs');
const path = require('path');

const basePath = path.join(__dirname, '../prisma/migrations/20260924053044_mysql_baseline/migration.sql');
const alignPath = path.join(__dirname, '../prisma/migrations/20261014120000_schema_alignment/migration.sql');
const schemaPath = path.join(__dirname, '../prisma/schema.prisma');

const baseline = fs.readFileSync(basePath, 'utf8');
const alignment = fs.readFileSync(alignPath, 'utf8');
const schema = fs.readFileSync(schemaPath, 'utf8');
const fullSql = baseline + '\n' + alignment;

// Parse Enums in schema.prisma
const enumBlocks = schema.split(/enum\s+/).slice(1);
const schemaEnums = {};
enumBlocks.forEach(block => {
  const name = block.match(/^([A-Za-z0-9_]+)/)[1];
  const body = block.substring(block.indexOf('{') + 1, block.indexOf('}'));
  const values = body.split(/\r?\n/).map(l => l.trim()).filter(l => l && !l.startsWith('//'));
  schemaEnums[name] = values;
});

// Parse Models in schema.prisma
const modelBlocks = schema.split(/model\s+/).slice(1);
const schemaModels = {};
modelBlocks.forEach(block => {
  const modelName = block.match(/^([A-Za-z0-9_]+)/)[1];
  const body = block.substring(block.indexOf('{') + 1, block.indexOf('}'));
  const lines = body.split(/\r?\n/).map(l => l.trim()).filter(l => l && !l.startsWith('//'));
  
  let tableName = modelName;
  const fields = [];
  const indexes = [];
  const uniqueConstraints = [];
  
  lines.forEach(l => {
    if (l.startsWith('@@map')) {
      tableName = l.match(/@@map\(["']([^"']+)["']\)/)[1];
    } else if (l.startsWith('@@unique')) {
      uniqueConstraints.push(l);
    } else if (l.startsWith('@@index')) {
      indexes.push(l);
    } else if (!l.startsWith('@@')) {
      const parts = l.split(/\s+/);
      const fieldName = parts[0];
      const fieldType = parts[1];
      const isOptional = fieldType.endsWith('?');
      const isArray = fieldType.endsWith('[]');
      const rawType = fieldType.replace(/[?\[\]]/g, '');
      fields.push({
        name: fieldName,
        type: rawType,
        isOptional,
        isArray,
        rawLine: l
      });
    }
  });

  schemaModels[modelName] = {
    tableName,
    fields,
    indexes,
    uniqueConstraints
  };
});

console.log('=== DEEP SCHEMA AUDIT REPORT ===');
console.log(`Auditing ${Object.keys(schemaModels).length} Prisma Models against Migration DDL...`);

let issues = 0;

for (const [modelName, m] of Object.entries(schemaModels)) {
  const tblRegex = new RegExp(`CREATE TABLE (?:IF NOT EXISTS )?[\`\"]?${m.tableName}[\`\"]?\\s*\\(([^;]+)\\)`, 'i');
  const match = fullSql.match(tblRegex);
  
  if (!match) {
    console.error(`[CRITICAL] Table ${m.tableName} for model ${modelName} NOT found in migration SQL!`);
    issues++;
    continue;
  }
  
  const ddlContent = match[1];
  
  // Extract all ALTER TABLE statements for this table
  const alterStatements = [];
  const alterRegex = new RegExp(`ALTER TABLE [\`\"]?${m.tableName}[\`\"]?\\s+([^;]+);`, 'gi');
  for (const alterMatch of fullSql.matchAll(alterRegex)) {
    alterStatements.push(alterMatch[1]);
  }
  const fullAlterContent = alterStatements.join('\n');
  
  // Check that every scalar field has a corresponding column in CREATE or ALTER
  m.fields.forEach(f => {
    // If it's a relation field referencing another model, Prisma doesn't create a column unless it has @relation(fields: [..])
    if (schemaModels[f.type] && f.rawLine.includes('@relation') && !f.rawLine.includes('fields:')) {
      return; // purely virtual relation side
    }
    if (f.isArray && schemaModels[f.type]) {
      return; // 1-to-many relation side
    }
    if (schemaModels[f.type]) {
      return;
    }
    
    // Check if column name or @map exists in DDL
    let colName = f.name;
    const mapCol = f.rawLine.match(/@map\(["']([^"']+)["']\)/);
    if (mapCol) colName = mapCol[1];
    
    // Check if column is in table CREATE TABLE DDL
    const colRegex = new RegExp(`[\`\"]?${colName}[\`\"]?\\s+([A-Za-z0-9_()]+)`, 'i');
    const colMatch = ddlContent.match(colRegex);
    
    // Check if column was added via ALTER TABLE
    const alterColRegex = new RegExp(`ADD COLUMN (?:IF NOT EXISTS )?[\`\"]?${colName}[\`\"]?\\s+([A-Za-z0-9_()]+)`, 'i');
    const alterMatch = fullAlterContent.match(alterColRegex);
    
    if (!colMatch && !alterMatch) {
      console.warn(`[WARN] Model ${modelName}.${f.name} -> Column '${colName}' not found in CREATE TABLE or ALTER TABLE for '${m.tableName}'`);
      issues++;
    }
  });
}

// Check enum values
console.log('\n--- Enum Audit ---');
for (const [enumName, values] of Object.entries(schemaEnums)) {
  const enumRegex = new RegExp(`ENUM\\s*\\(([^)]+)\\)`, 'gi');
  let matchedAll = false;
  let allFoundValues = new Set();
  for (const m of fullSql.matchAll(enumRegex)) {
    const vals = m[1].split(',').map(v => v.trim().replace(/['"]/g, ''));
    vals.forEach(v => allFoundValues.add(v));
    const common = values.filter(v => vals.includes(v));
    if (common.length === values.length) {
      matchedAll = true;
      break;
    }
  }
  if (matchedAll) {
    console.log(`[ENUM OK] Enum ${enumName} (${values.length} values) completely verified in DDL.`);
  } else {
    const missing = values.filter(v => !allFoundValues.has(v));
    if (missing.length === 0) {
      console.log(`[ENUM OK] Enum ${enumName} values all present across migrations.`);
    } else {
      console.warn(`[ENUM WARN] Enum ${enumName} missing values in DDL: [${missing.join(', ')}]`);
      issues++;
    }
  }
}

console.log(`\nAudit completed with ${issues} structural warnings/issues.`);
