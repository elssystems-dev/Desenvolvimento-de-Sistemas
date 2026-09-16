const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 5000;

// Configuração do CORS e Middleware para JSON
app.use(cors());
app.use(express.json());

// Dados em memória
let produtos = [
  {
    id: 1,
    nome: "Teclado Mecânico RGB",
    preco: 249.9,
    categoria: "Eletrônicos",
    descricao: "Teclado com switches azuis.",
  },
  {
    id: 2,
    nome: "Mouse Gamer 16000 DPI",
    preco: 129.9,
    categoria: "Eletrônicos",
    descricao: "Sensor óptico de alta precisão.",
  },
];

// GET: Listar todos os produtos
app.get("/api/products", (req, res) => {
  res.json(produtos);
});

// POST: Criar novo produto
app.post("/api/products", (req, res) => {
  const { nome, preco, categoria, descricao } = req.body;

  if (!nome || !preco || !categoria) {
    return res.status(400).json({ mensagem: "Campos obrigatórios ausentes." });
  }

  const novoProduto = {
    id: Date.now(),
    nome,
    preco: parseFloat(preco),
    categoria,
    descricao: descricao || "",
  };

  produtos.push(novoProduto);
  res.status(201).json(novoProduto);
});

// PUT: Atualizar produto existente
app.put("/api/products/:id", (req, res) => {
  const { id } = req.params;
  const { nome, preco, categoria, descricao } = req.body;

  const index = produtos.findIndex((p) => p.id === Number(id));

  if (index === -1) {
    return res.status(404).json({ mensagem: "Produto não encontrado." });
  }

  produtos[index] = {
    ...produtos[index],
    nome,
    preco: parseFloat(preco),
    categoria,
    descricao,
  };

  res.json(produtos[index]);
});

// DELETE: Excluir produto
app.delete("/api/products/:id", (req, res) => {
  const { id } = req.params;
  const index = produtos.findIndex((p) => p.id === Number(id));

  if (index === -1) {
    return res.status(404).json({ mensagem: "Produto não encontrado." });
  }

  produtos = produtos.filter((p) => p.id !== Number(id));
  res.status(200).json({ mensagem: "Produto removido com sucesso." });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
