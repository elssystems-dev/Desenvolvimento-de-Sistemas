# 🚀 SyncPoint - Backend Mock REST API (Node.js & json-server)

Este diretório contém o servidor REST local desenvolvido com **Node.js** e **json-server** para simular o backend corporativo do **SyncPoint**.

Ele substitui o Firebase por uma arquitetura REST simples, direta e alinhada ao conteúdo do curso de Desenvolvimento de Sistemas.

---

## 📦 Como Iniciar o Servidor

### 1. Pré-requisito
Certifique-se de ter o [Node.js](https://nodejs.org/) instalado em seu computador.

### 2. Instalar dependências (apenas na primeira vez)
No terminal, entre nesta pasta e instale os pacotes:
```bash
cd server
npm install
```

### 3. Rodar o Servidor
Execute um dos comandos abaixo:

```bash
# Opção 1: Usando o script Node.js customizado (com logs e CORS habilitado)
npm start

# Opção 2: Usando o json-server diretamente com hot-reload no arquivo db.json
npm run dev

# Opção 3: Usando npx diretamente sem instalar globalmente
npx json-server --watch db.json --port 3000 --host 0.0.0.0
```

O servidor iniciará na porta **3000**:
- **Acesso pelo navegador / Postman:** `http://localhost:3000`
- **Acesso pelo Emulador Android:** `http://10.0.2.2:3000`
- **Acesso por dispositivo físico na mesma rede Wi-Fi:** `http://<SEU_IP_LOCAL>:3000`

---

## 📑 Endpoints Disponíveis

| Método | Endpoint | Descrição |
| :--- | :--- | :--- |
| `GET` | `/status` | Verifica a saúde e status do servidor |
| `GET` | `/users` | Lista todos os usuários cadastrados |
| `GET` | `/users?email={email}` | Busca usuário por e-mail |
| `GET` | `/users?nif={nif}` | Busca usuário por NIF corporativo |
| `POST` | `/users` | Cadastra novo colaborador |
| `PUT` | `/users/:id` | Atualiza dados do colaborador |
| `GET` | `/time_records?userId={id}` | Histórico de registros de ponto do usuário |
| `POST` | `/time_records` | Registra novo ponto (com geofence e hash SHA-256) |
| `GET` | `/workplaces` | Lista sedes corporativas cadastradas |

---

## 👥 Credenciais Pré-cadastradas para Teste

| Nome | NIF | E-mail | Senha | Cargo | Biometria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Carlos Oliveira | `123456` | `carlos.oliveira@syncpoint.internal` | `123456` | Eng. Software | Ativada |
| Mariana Souza | `654321` | `mariana.souza@syncpoint.internal` | `123456` | Analista RH | Desativada |
