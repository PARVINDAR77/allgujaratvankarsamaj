const fs = require('fs');
const path = require('path');

const binPath = path.join(__dirname, '../application/build/web/assets/AssetManifest.bin');
const binJsonPath = path.join(__dirname, '../application/build/web/assets/AssetManifest.bin.json');

const newAssets = [
  'assets/images/portal_card_prernadata.png',
  'assets/images/portal_card_superstars.png',
  'assets/images/portal_card_ratna.png'
];

// In standard message codec, each asset entry in the map is:
// key: string (type 7) -> asset path
// value: list (type 12) with 1 element -> map (type 13) with 1 element: key "asset" (type 7) -> value asset path (type 7)
function encodeString(str) {
  const buf = Buffer.from(str, 'utf8');
  if (buf.length < 254) {
    return Buffer.concat([Buffer.from([7, buf.length]), buf]);
  } else {
    const lenBuf = Buffer.alloc(3);
    lenBuf[0] = 7;
    lenBuf[1] = 254;
    lenBuf.writeUInt16LE(buf.length, 1);
    return Buffer.concat([lenBuf, buf]);
  }
}

function encodeAssetEntry(assetPath) {
  const key = encodeString(assetPath);
  // list with 1 element: byte 12, length 1
  // inside list: map with 1 entry: byte 13, length 1
  // key: "asset", value: assetPath
  const mapKey = encodeString('asset');
  const mapVal = encodeString(assetPath);
  const entryVal = Buffer.concat([
    Buffer.from([12, 1, 13, 1]),
    mapKey,
    mapVal
  ]);
  return Buffer.concat([key, entryVal]);
}

const currentBin = fs.readFileSync(binPath);
// Byte 0 is 13 (Map). Next is size.
let currentCount = currentBin[1];
console.log('Current asset count:', currentCount);

const newEntriesBufs = [];
for (const a of newAssets) {
  newEntriesBufs.push(encodeAssetEntry(a));
}
const extraBytes = Buffer.concat(newEntriesBufs);

const updatedCount = currentCount + newAssets.length;
const updatedBin = Buffer.concat([
  Buffer.from([13, updatedCount]),
  currentBin.slice(2),
  extraBytes
]);

fs.writeFileSync(binPath, updatedBin);
console.log('Updated AssetManifest.bin, new size:', updatedBin.length);

// Now update AssetManifest.bin.json
// In Flutter web, AssetManifest.bin.json contains JSON array of byte values of the base64 string
const base64Str = updatedBin.toString('base64');
const jsonArray = [];
for (let i = 0; i < base64Str.length; i++) {
  jsonArray.push(base64Str.charCodeAt(i));
}
fs.writeFileSync(binJsonPath, JSON.stringify(jsonArray));
console.log('Updated AssetManifest.bin.json, length:', jsonArray.length);
