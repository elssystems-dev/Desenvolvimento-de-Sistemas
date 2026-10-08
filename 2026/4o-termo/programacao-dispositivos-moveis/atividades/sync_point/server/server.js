// SyncPoint - Backend Mock Server com json-server
const path = require('path');
const fs = require('fs');

const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';
const DB_FILE = path.join(__dirname, 'db.json');

// Verifica se o db.json existe
if (!fs.existsSync(DB_FILE)) {
  console.error(`❌ Arquivo db.json não encontrado em: ${DB_FILE}`);
  process.exit(1);
}

// Tenta inicializar com json-server (se instalado)
try {
  const jsonServer = require('json-server');
  const server = jsonServer.create();
  const router = jsonServer.router(DB_FILE);
  const middlewares = jsonServer.defaults({ noCors: false });

  server.use(middlewares);
  server.use(jsonServer.bodyParser);

  // Rota de status/healthcheck
  server.get('/status', (req, res) => {
    res.json({
      status: 'online',
      service: 'SyncPoint json-server REST API',
      timestamp: new Date().toISOString()
    });
  });

  // Interceptor para logs amigáveis no terminal
  server.use((req, res, next) => {
    const timestamp = new Date().toLocaleTimeString();
    console.log(`[${timestamp}] 📡 ${req.method} ${req.url}`);
    next();
  });

  server.use(router);

  server.listen(PORT, HOST, () => {
    console.log('='.repeat(60));
    console.log('🚀 SyncPoint REST API (json-server) está rodando!');
    console.log(`📡 Localhost:     http://localhost:${PORT}`);
    console.log(`📱 Android Emu:   http://10.0.2.2:${PORT}`);
    console.log(`🌐 Rede (0.0.0.0): http://${HOST}:${PORT}`);
    console.log('='.repeat(60));
    console.log('Rotas disponíveis:');
    console.log(`  - GET/POST       /users`);
    console.log(`  - GET/POST       /time_records`);
    console.log(`  - GET/POST       /workplaces`);
    console.log(`  - GET            /status`);
    console.log('='.repeat(60));
  });
} catch (err) {
  // Fallback nativo caso json-server ainda não tenha sido instalado via npm
  console.warn('⚠️  Pacote json-server não encontrado localmente.');
  console.log('Iniciando servidor REST nativo Node.js com db.json...');

  const http = require('http');
  const url = require('url');

  function readDb() {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  }

  function writeDb(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf8');
  }

  const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }

    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname.replace(/\/$/, '') || '/';
    const query = parsedUrl.query;
    const parts = pathname.split('/').filter(Boolean);
    const resource = parts[0];
    const id = parts[1];

    console.log(`[${new Date().toLocaleTimeString()}] 📡 ${req.method} ${req.url}`);

    if (pathname === '/status') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'online', service: 'SyncPoint Fallback Native Server', timestamp: new Date().toISOString() }));
      return;
    }

    const db = readDb();

    if (!resource || !db[resource]) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Recurso não encontrado' }));
      return;
    }

    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      let parsedBody = {};
      if (body) {
        try { parsedBody = JSON.parse(body); } catch (_) {}
      }

      const collection = db[resource];

      if (req.method === 'GET') {
        if (id) {
          const item = collection.find(i => String(i.id) === String(id));
          if (!item) {
            res.writeHead(404, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Item não encontrado' }));
            return;
          }
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(item));
        } else {
          // Filtragem simples por query params
          let result = collection.filter(item => {
            for (const key of Object.keys(query)) {
              if (key.startsWith('_')) continue; // Ignora _sort etc
              if (String(item[key]).toLowerCase() !== String(query[key]).toLowerCase()) {
                return false;
              }
            }
            return true;
          });
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result));
        }
      } else if (req.method === 'POST') {
        const newItem = {
          id: parsedBody.id || `${resource}-${Date.now()}`,
          ...parsedBody
        };
        // Se já existe item com mesmo ID, atualiza
        const existingIdx = collection.findIndex(i => String(i.id) === String(newItem.id));
        if (existingIdx >= 0) {
          collection[existingIdx] = newItem;
        } else {
          collection.push(newItem);
        }
        writeDb(db);
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newItem));
      } else if (req.method === 'PUT' || req.method === 'PATCH') {
        const targetId = id || parsedBody.id;
        const itemIdx = collection.findIndex(i => String(i.id) === String(targetId));
        if (itemIdx === -1) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Item não encontrado para atualização' }));
          return;
        }
        collection[itemIdx] = { ...collection[itemIdx], ...parsedBody };
        writeDb(db);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(collection[itemIdx]));
      } else if (req.method === 'DELETE') {
        const targetId = id;
        db[resource] = collection.filter(i => String(i.id) !== String(targetId));
        writeDb(db);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
      } else {
        res.writeHead(405, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Método não suportado' }));
      }
    });
  });

  server.listen(PORT, HOST, () => {
    console.log('='.repeat(60));
    console.log(`🚀 Servidor nativo REST online na porta ${PORT}!`);
    console.log(`📡 Localhost:     http://localhost:${PORT}`);
    console.log(`📱 Android Emu:   http://10.0.2.2:${PORT}`);
    console.log('='.repeat(60));
  });
}
