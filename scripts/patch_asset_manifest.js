const fs = require('fs');
const path = require('path');

class StandardMessageCodecReader {
  constructor(b) { this.b = b; this.pos = 0; }
  readByte() { return this.b[this.pos++]; }
  readSize() {
    const v = this.readByte();
    if (v < 254) return v;
    if (v === 254) {
      const s = this.b.readUInt16BE(this.pos);
      this.pos += 2;
      return s;
    }
    const s = this.b.readUInt32BE(this.pos);
    this.pos += 4;
    return s;
  }
  readMessage() {
    const type = this.readByte();
    if (type === 0) return null;
    if (type === 1) return true;
    if (type === 2) return false;
    if (type === 7) {
      const len = this.readSize();
      const str = this.b.toString('utf8', this.pos, this.pos + len);
      this.pos += len;
      return str;
    }
    if (type === 12) {
      const len = this.readSize();
      const list = [];
      for (let i = 0; i < len; i++) list.push(this.readMessage());
      return list;
    }
    if (type === 13) {
      const len = this.readSize();
      const map = {};
      for (let i = 0; i < len; i++) {
        const k = this.readMessage();
        const v = this.readMessage();
        map[k] = v;
      }
      return map;
    }
    throw new Error('Unknown StandardMessageCodec type: ' + type + ' at pos ' + (this.pos - 1));
  }
}

class StandardMessageCodecWriter {
  constructor() { this.bufs = []; }
  writeByte(v) { this.bufs.push(Buffer.from([v])); }
  writeSize(n) {
    if (n < 254) {
      this.writeByte(n);
    } else if (n <= 65535) {
      const b = Buffer.alloc(3);
      b[0] = 254;
      b.writeUInt16BE(n, 1);
      this.bufs.push(b);
    } else {
      const b = Buffer.alloc(5);
      b[0] = 255;
      b.writeUInt32BE(n, 1);
      this.bufs.push(b);
    }
  }
  writeMessage(val) {
    if (val === null) {
      this.writeByte(0);
    } else if (val === true) {
      this.writeByte(1);
    } else if (val === false) {
      this.writeByte(2);
    } else if (typeof val === 'string') {
      this.writeByte(7);
      const strBuf = Buffer.from(val, 'utf8');
      this.writeSize(strBuf.length);
      this.bufs.push(strBuf);
    } else if (Array.isArray(val)) {
      this.writeByte(12);
      this.writeSize(val.length);
      for (const item of val) this.writeMessage(item);
    } else if (typeof val === 'object') {
      const keys = Object.keys(val);
      this.writeByte(13);
      this.writeSize(keys.length);
      for (const k of keys) {
        this.writeMessage(k);
        this.writeMessage(val[k]);
      }
    }
  }
  toBuffer() { return Buffer.concat(this.bufs); }
}

function patchManifest() {
  const binPath = path.join(__dirname, '../application/build/web/assets/AssetManifest.bin');
  const binJsonPath = path.join(__dirname, '../application/build/web/assets/AssetManifest.bin.json');

  const origBuf = fs.readFileSync(binPath);
  const reader = new StandardMessageCodecReader(origBuf);
  const map = reader.readMessage();

  console.log('Original asset entries:', Object.keys(map).length);

  // Add the 3 royal portal cards cleanly
  const portalAssets = [
    'assets/images/portal_card_prernadata.png',
    'assets/images/portal_card_superstars.png',
    'assets/images/portal_card_ratna.png'
  ];

  for (const assetKey of portalAssets) {
    map[assetKey] = [{ asset: assetKey }];
    console.log('Registered asset in manifest:', assetKey);
  }

  const writer = new StandardMessageCodecWriter();
  writer.writeMessage(map);
  const newBuf = writer.toBuffer();

  // Test decoding the new buffer to be 100% sure it is valid
  const testReader = new StandardMessageCodecReader(newBuf);
  const decoded = testReader.readMessage();
  console.log('Verification: re-decoded entry count:', Object.keys(decoded).length);
  for (const assetKey of portalAssets) {
    if (!decoded[assetKey]) throw new Error('Missing ' + assetKey + ' in decoded manifest!');
  }
  console.log('AssetManifest verification passed 100%!');

  fs.writeFileSync(binPath, newBuf);
  fs.writeFileSync(binJsonPath, JSON.stringify(newBuf.toString('base64')));
  console.log('Saved AssetManifest.bin (' + newBuf.length + ' bytes) and AssetManifest.bin.json');

  // Copy images to both possible paths
  const srcDir = path.join(__dirname, '../application/assets/images');
  const destDir1 = path.join(__dirname, '../application/build/web/assets/assets/images');
  const destDir2 = path.join(__dirname, '../application/build/web/assets/images');

  if (!fs.existsSync(destDir1)) fs.mkdirSync(destDir1, { recursive: true });
  if (!fs.existsSync(destDir2)) fs.mkdirSync(destDir2, { recursive: true });

  const files = ['portal_card_prernadata.png', 'portal_card_superstars.png', 'portal_card_ratna.png'];
  for (const file of files) {
    const src = path.join(srcDir, file);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, path.join(destDir1, file));
      fs.copyFileSync(src, path.join(destDir2, file));
      console.log('Copied ' + file + ' to web assets build directories.');
    }
  }
}

patchManifest();
