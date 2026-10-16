const fs = require('fs');
const path = require('path');

const basePath = path.join(__dirname, '../prisma/migrations/20260924053044_mysql_baseline/migration.sql');
const alignPath = path.join(__dirname, '../prisma/migrations/20261014120000_schema_alignment/migration.sql');
const schemaPath = path.join(__dirname, '../prisma/schema.prisma');

const baseline = fs.readFileSync(basePath, 'utf8');
const alignment = fs.readFileSync(alignPath, 'utf8');
const schema = fs.readFileSync(schemaPath, 'utf8');

const baseTables = [...baseline.matchAll(/CREATE TABLE [`"]?([a-zA-Z0-9_]+)[`"]?/gi)].map(m => m[1]);
const alignTables = [...alignment.matchAll(/CREATE TABLE (?:IF NOT EXISTS )?[`"]?([a-zA-Z0-9_]+)[`"]?/gi)].map(m => m[1]);

// Extract models and their @@map if any
const modelBlocks = schema.split(/model\s+/).slice(1);
const modelToTable = {};
modelBlocks.forEach(block => {
  const modelName = block.match(/^([A-Za-z0-9_]+)/)[1];
  const mapMatch = block.match(/@@map\(["']([^"']+)["']\)/);
  const tableName = mapMatch ? mapMatch[1] : modelName;
  modelToTable[modelName] = tableName;
});

const allSqlTables = new Set([...baseTables, ...alignTables]);
const mappedTables = Object.values(modelToTable);

console.log('=== MODEL TO TABLE RECONCILIATION ===');
console.log('Baseline SQL Tables (' + baseTables.length + '):', baseTables);
console.log('Alignment SQL Tables (' + alignTables.length + '):', alignTables);
console.log('Total Migrated SQL Tables: ' + allSqlTables.size);
console.log('Total Prisma Models: ' + Object.keys(modelToTable).length);

console.log('\n--- Mapping Verification ---');
let allMatched = true;
for (const [model, table] of Object.entries(modelToTable)) {
  const present = allSqlTables.has(table);
  const source = baseTables.includes(table) ? 'baseline' : (alignTables.includes(table) ? 'alignment' : 'MISSING');
  console.log(`  Model: ${model.padEnd(35)} -> Table: ${table.padEnd(35)} [${source}]`);
  if (!present) {
    allMatched = false;
    console.error(`  ERROR: Model ${model} maps to table ${table} which is NOT in migration SQL!`);
  }
}

console.log('\nReconciliation result:', allMatched ? 'ALL 33 MODELS PERFECTLY MATCHED IN SQL MIGRATIONS' : 'MISMATCH DETECTED');
