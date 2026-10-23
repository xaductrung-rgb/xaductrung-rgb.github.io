import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PORT = process.env.PORT || 8088;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.apk': 'application/vnd.android.package-archive',
  '.aab': 'application/octet-stream'
};

const server = http.createServer((req, res) => {
  const safeUrl = (req.url || '/').split('?')[0];
  let filePath = path.join(__dirname, safeUrl === '/' ? 'index.html' : safeUrl);

  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    filePath = path.join(__dirname, 'index.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Lỗi đọc file máy chủ nội bộ');
      return;
    }
    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache'
    });
    res.end(content);
  });
});

function getLocalLanIp() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name] || []) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return '127.0.0.1';
}

server.listen(PORT, '0.0.0.0', () => {
  const lanIp = getLocalLanIp();
  console.log('====================================================');
  console.log(' A4 CLEANSCAN PRO - WEB NOI BO DA KHOI DONG!');
  console.log(` -> Truy cap tren may tinh: http://localhost:${PORT}`);
  console.log(` -> Truy cap tren dien thoai chung WiFi: http://${lanIp}:${PORT}`);
  console.log('====================================================');
});
